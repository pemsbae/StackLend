(define-map collateral-balances principal uint)
(define-map loan-balances principal uint)

(define-constant collateral-ratio-threshold u150) ;; Minimum ratio (150%)
(define-constant borrow-limit u70) ;; Borrowing limit (70% of collateral value)
(define-data-var interest-rate uint u5) ;; Fixed annual interest rate (5%), now adjustable

(define-data-var protocol-reserves uint u0) ;; Tracks total reserves in the protocol
(define-data-var accrued-interest uint u0) ;; Tracks total accrued interest


;; Function: Accrue interest
(define-private (accrue-interest)
    (let ((total-loan (default-to u0 (map-get? loan-balances tx-sender)))
          (interest (* total-loan (var-get interest-rate))))
        (var-set accrued-interest (+ (var-get accrued-interest) interest))
    )
)


;; Function: Deposit collateral
(define-public (deposit-collateral (amount uint))
  (begin
    (asserts! (> amount u0) (err u100)) ;; Amount must be greater than zero
    (map-set collateral-balances tx-sender (+ amount (default-to u0 (map-get? collateral-balances tx-sender))))
    (ok amount)
  )
)

;; Function: Borrow tokens
(define-public (borrow-tokens (amount uint))
  (begin
    (accrue-interest) ;; Accrue interest before borrowing
    (let ((collateral (default-to u0 (map-get? collateral-balances tx-sender))))
      (asserts! (> collateral u0) (err u101)) ;; Must have collateral
      (let ((max-borrow (/ (* collateral borrow-limit) u100)))
        (asserts! (<= amount max-borrow) (err u102)) ;; Cannot borrow more than limit
        (map-set loan-balances tx-sender (+ amount (default-to u0 (map-get? loan-balances tx-sender))))
        (var-set protocol-reserves (+ amount (var-get protocol-reserves)))
        (ok amount)
      )
    )
  )
)

;; Function: Repay loan
(define-public (repay-loan (amount uint))
  (begin
    (accrue-interest) ;; Accrue interest before repayment
    (let ((loan (default-to u0 (map-get? loan-balances tx-sender))))
      (asserts! (> loan u0) (err u103)) ;; Must have an outstanding loan
      (let ((repay-amount (if (>= amount loan) loan amount)))
        (map-set loan-balances tx-sender (- loan repay-amount))
        (var-set protocol-reserves (- (var-get protocol-reserves) repay-amount))
        (ok repay-amount)
      )
    )
  )
)

;; Function: Liquidate under-collateralized loans
(define-public (liquidate (user principal))
  (begin
    (accrue-interest) ;; Accrue interest before liquidation
    (let ((collateral (default-to u0 (map-get? collateral-balances user)))
          (loan (default-to u0 (map-get? loan-balances user))))
      (asserts! (> loan u0) (err u104)) ;; Must have an outstanding loan
      (let ((collateral-ratio (/ (* collateral u100) loan)))
        (asserts! (< collateral-ratio collateral-ratio-threshold) (err u105)) ;; Must be under-collateralized
        (map-delete collateral-balances user)
        (map-delete loan-balances user)
        (var-set protocol-reserves (+ collateral (var-get protocol-reserves)))
        (ok collateral)
      )
    )
  )
)

;; Function: Set interest rate (governance function)
(define-public (set-interest-rate (new-rate uint))
    (begin
        (asserts! (is-eq tx-sender (as-contract tx-sender)) (err u200)) ;; Only the contract owner can call this
        (asserts! (and (>= new-rate u1) (<= new-rate u100)) (err u201)) ;; Interest rate must be between 1% and 100%
        (var-set interest-rate new-rate)
        (ok true)
    )
)

;; Read-only function: Get collateral ratio
(define-read-only (get-collateral-ratio (user principal))
  (let ((collateral (default-to u0 (map-get? collateral-balances user)))
        (loan (default-to u0 (map-get? loan-balances user))))
    (if (is-eq loan u0) 
        u0 
        (/ (* collateral u100) loan))
  )
)

;; Read-only function: Get user balances
(define-read-only (get-user-balances (user principal))
  {
    collateral: (default-to u0 (map-get? collateral-balances user)),
    loan: (default-to u0 (map-get? loan-balances user))
  }
)

;; Read-only function: Get protocol reserves and accrued interest
(define-read-only (get-protocol-status)
    {
        reserves: (var-get protocol-reserves),
        accrued-interest: (var-get accrued-interest),
        interest-rate: (var-get interest-rate)
    }
)
