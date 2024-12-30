(define-map collateral-balances principal uint)
(define-map loan-balances principal uint)

(define-constant collateral-ratio-threshold u150) ;; Minimum ratio (150%)
(define-constant borrow-limit u70) ;; Borrowing limit (70% of collateral value)
(define-constant interest-rate u5) ;; Fixed annual interest rate (5%)

(define-data-var protocol-reserves uint u0) ;; Tracks total reserves in the protocol

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

;; Function: Repay loan
(define-public (repay-loan (amount uint))
  (let ((loan (default-to u0 (map-get? loan-balances tx-sender))))
    (asserts! (> loan u0) (err u103)) ;; Must have an outstanding loan
    (let ((repay-amount (if (>= amount loan) loan amount)))
      (map-set loan-balances tx-sender (- loan repay-amount))
      (var-set protocol-reserves (- (var-get protocol-reserves) repay-amount))
      (ok repay-amount)
    )
  )
)

;; Function: Liquidate under-collateralized loans
(define-public (liquidate (user principal))
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