# Dividend Token Smart Contract

## Features

- Fungible token implementation following SIP-010 standard
- Automated dividend distribution system
- Proportional dividend calculations based on token holdings
- Secure dividend claiming mechanism
- Protected admin functions for token minting and dividend distribution

## Contract Functions

### Administrative Functions

#### `mint`
```clarity
(mint (amount uint) (recipient principal))
```
- Mints new tokens to the specified recipient
- Only callable by contract owner
- Returns: `(ok true)` on success, `(err u100)` if unauthorized

#### `distribute-dividends`
```clarity
(distribute-dividends (amount uint))
```
- Distributes dividends to all token holders
- Only callable by contract owner
- Returns: `(ok true)` on success, `(err u101)` if total supply is 0

### User Functions

#### `claim-dividends`
```clarity
(claim-dividends)
```
- Claims accumulated dividends for the caller
- Returns: `(ok true)` if successful, `(err u101)` if no dividends to claim

#### `transfer`
```clarity
(transfer (amount uint) (sender principal) (recipient principal))
```
- Transfers tokens between accounts
- Automatically handles dividend claims before transfer
- Returns: `(ok true)` on success, various error codes on failure

#### `get-pending-dividends`
```clarity
(get-pending-dividends (user principal))
```
- Read-only function to check pending dividends
- Returns: uint representing pending dividend amount

## Error Codes

- `ERR_UNAUTHORIZED (u100)`: Caller is not authorized to perform this action
- `ERR_INSUFFICIENT_BALANCE (u101)`: Insufficient balance or no dividends to claim
- `ERR_FAILED_TO_CLAIM (u102)`: Failed to claim dividends during transfer

## Installation

1. Install the [Clarinet](https://github.com/hirosystems/clarinet) development environment
2. Clone this repository
3. Navigate to the project directory

```bash
clarinet new my-dividend-token
cd my-dividend-token
```

## Deployment

1. Update the contract settings in `Clarinet.toml`
2. Test the contract locally:
```bash
clarinet test
```
3. Deploy to testnet:
```bash
clarinet deploy --testnet
```

## Testing

Create test cases in the `tests` directory. Example test structure:

```clarity
(test-claim-dividends
    (let
        ((wallet-1 (ts-generate-key "wallet-1")))
        ;; Setup test scenario
        (mint u1000 wallet-1)
        (distribute-dividends u100)
        ;; Assert expected behavior
        (assert-ok (claim-dividends))
    )
)
```

## Security Considerations

1. The contract implements access controls for administrative functions
2. Dividend calculations use scaling factors to maintain precision
3. Transfer function includes automatic dividend claiming to prevent dividend loss
4. Users should be aware that dividend claims must be processed before transfers

## Future Improvements

- Add events for tracking dividend distributions and claims
- Implement more sophisticated dividend calculation mechanisms
- Add support for different dividend token types
- Enhance precision handling for large numbers
- Add timelock mechanisms for dividend distributions