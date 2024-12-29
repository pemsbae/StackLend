# StackLend: Decentralized Lending Protocol

## Overview
StackLend is a decentralized lending protocol built on the Stacks blockchain. It enables users to deposit tokens as collateral, borrow tokens against their collateral, and repay loans while maintaining a transparent and trustless system.

## Features
- **Deposit Collateral**: Users can deposit tokens as collateral to participate in the lending protocol.
- **Borrow Tokens**: Borrow tokens based on the collateral value with defined borrowing limits.
- **Repay Loans**: Repay loans partially or fully to retrieve collateral.
- **Liquidation**: Liquidate under-collateralized positions to maintain protocol solvency.
- **Collateral Ratio Calculation**: Provides insights into the user's current collateral ratio.

## Core Functions
### Public Functions
1. `deposit-collateral (amount uint)`
   - Allows users to deposit tokens as collateral.
   - Fails if the amount is zero or less.

2. `borrow-tokens (amount uint)`
   - Enables borrowing of tokens within the collateral limit.
   - Fails if the user exceeds their borrowing capacity.

3. `repay-loan (amount uint)`
   - Allows users to repay their outstanding loans.
   - Automatically adjusts loan balances.

4. `liquidate (user principal)`
   - Liquidates loans for users whose collateral ratio falls below the threshold.
   - Transfers the user's collateral to protocol reserves.

### Read-Only Functions
1. `get-collateral-ratio (user principal)`
   - Returns the collateral-to-loan ratio for a specific user.

2. `get-user-balances (user principal)`
   - Provides the collateral and loan balances for a specific user.

## Data Structures
- **Maps**:
  - `collateral-balances`: Tracks collateral deposits per user.
  - `loan-balances`: Tracks outstanding loan amounts per user.
- **Variables**:
  - `protocol-reserves`: Tracks the total reserves in the protocol.

## Constants
- `collateral-ratio-threshold`: Minimum collateral ratio (150%).
- `borrow-limit`: Maximum borrowing limit (70% of collateral value).
- `interest-rate`: Fixed annual interest rate (5%).

## Installation
1. Clone the repository:
   ```bash
   git clone <repository-url>
   ```
2. Navigate to the project directory:
   ```bash
   cd stacklend
   ```
3. Install dependencies:
   ```bash
   npm install
   ```
4. Compile and test the Clarity contract using Clarinet:
   ```bash
   clarinet check
   clarinet test
   ```

## Usage
1. Deploy the contract to a Stacks testnet or mainnet.
2. Use a compatible wallet or UI to interact with the protocol.

## Testing
- **Unit Tests**: Written using Clarinet to ensure robust functionality.
- **Edge Cases**: Simulates scenarios like liquidation and over-borrowing.

## Future Enhancements
- Implement dynamic interest rates based on market conditions.
- Add tokenized debt positions to enable loan trading.
- Create a front-end interface for seamless user interaction.

## Contributing
Contributions are welcome! Please open an issue or submit a pull request to propose improvements or report bugs.

## License
This project is licensed under the MIT License. See the LICENSE file for details.

## Contact
For inquiries or collaboration, contact [your email/contact info].