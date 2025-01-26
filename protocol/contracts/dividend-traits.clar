;; Title: Enhanced Dividend Traits Contract
;; Description: Defines standard interfaces for dividend-supporting tokens with multi-token support and enhanced security

;; ========================================
;; Constants and Configuration
;; ========================================

;; Precision factor for dividend calculations (6 decimal places)
(define-constant PRECISION_FACTOR u1000000)

;; Maximum number of tokens that can be registered in the registry
(define-constant MAX_REGISTERED_TOKENS u128)

;; Minimum time (in blocks) between dividend distributions
(define-constant MIN_DISTRIBUTION_INTERVAL u100)

;; Minimum amount for dividend distributions
(define-constant MIN_DISTRIBUTION_AMOUNT u1000)

;; Maximum dividend rate per block (10% = 100000)
(define-constant MAX_DIVIDEND_RATE u100000)

;; Cooldown period for consecutive claims (in blocks)
(define-constant CLAIM_COOLDOWN_PERIOD u10)

;; Distribution types
(define-constant DISTRIBUTION_TYPE_IMMEDIATE u1)
(define-constant DISTRIBUTION_TYPE_SCHEDULED u2)
(define-constant DISTRIBUTION_TYPE_VESTED u3)

;; ========================================
;; Error Codes
;; ========================================

;; Authorization and Access Control
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_INVALID_CALLER (err u101))
(define-constant ERR_NOT_TOKEN_OWNER (err u102))

;; Token Registration and Management
(define-constant ERR_INVALID_TOKEN (err u110))
(define-constant ERR_ALREADY_REGISTERED (err u111))
(define-constant ERR_NOT_REGISTERED (err u112))
(define-constant ERR_REGISTRY_FULL (err u113))
(define-constant ERR_TOKEN_FROZEN (err u114))

;; Distribution Operations
(define-constant ERR_INVALID_AMOUNT (err u120))
(define-constant ERR_INVALID_HEIGHT (err u121))
(define-constant ERR_NO_PENDING_DIVIDENDS (err u122))
(define-constant ERR_DISTRIBUTION_EXISTS (err u123))
(define-constant ERR_DISTRIBUTION_NOT_FOUND (err u124))
(define-constant ERR_DISTRIBUTION_ALREADY_PROCESSED (err u125))
(define-constant ERR_BELOW_MINIMUM_AMOUNT (err u126))
(define-constant ERR_DISTRIBUTION_TOO_FREQUENT (err u127))
(define-constant ERR_EXCEEDS_MAX_RATE (err u128))

;; Security and Rate Limiting
(define-constant ERR_COOLDOWN_ACTIVE (err u140))
(define-constant ERR_RATE_LIMIT_EXCEEDED (err u141))
(define-constant ERR_EMERGENCY_SHUTDOWN (err u142))
(define-constant ERR_INVALID_SIGNATURE (err u143))

;; System and Implementation
(define-constant ERR_ARITHMETIC_ERROR (err u130))
(define-constant ERR_NOT_IMPLEMENTED (err u131))
(define-constant ERR_SYSTEM_FAILURE (err u132))

;; ========================================
;; Core Traits
;; ========================================

;; Core dividend token trait with enhanced security and multi-token support
(define-trait enhanced-dividend-token-trait
    (
        ;; Basic token info
        (get-total-supply () (response uint uint))
        (get-dividends-per-token () (response uint uint))
        (get-pending-dividends (principal) (response uint uint))
        
        ;; Enhanced dividend claims
        (claim-dividends () (response bool uint))
        (claim-specific-dividend (uint) (response bool uint))
        (claim-multi-token-dividends (principal) (response bool uint))
        
        ;; Security and validation
        (has-pending-dividends (principal) (response bool uint))
        (get-last-claim-height (principal) (response uint uint))
        (get-total-distributed () (response uint uint))
        (validate-claim (principal) (response bool uint))
        
        ;; Emergency controls
        (set-emergency-shutdown (bool) (response bool uint))
        (is-shutdown () (response bool uint))
        
        ;; Rate limiting
        (is-rate-limited (principal) (response bool uint))
        (reset-rate-limit (principal) (response bool uint))
    )
)

;; Enhanced distributor trait with vesting and scheduling
(define-trait enhanced-dividend-distributor-trait
    (
        ;; Distribution methods
        (distribute-dividends (uint) (response bool uint))
        (schedule-distribution (uint uint) (response bool uint))
        (distribute-with-vesting (uint uint uint) (response bool uint))
        (cancel-distribution (uint) (response bool uint))
        
        ;; Batch operations
        (batch-distribute (principal uint) (response bool uint))
        
        ;; Distribution info and validation
        (get-distribution-info (uint) (response {
            amount: uint,
            height: uint,
            distributed: bool,
            distribution-type: uint,
            vesting-period: uint
        } uint))
        (validate-distribution (uint uint) (response bool uint))
        
        ;; Security features
        (set-distribution-guardian (principal) (response bool uint))
        (require-guardian-signature (bool) (response bool uint))
    )
)

;; Registry trait with enhanced token management
(define-trait enhanced-dividend-registry-trait
    (
        ;; Token registration
        (register-dividend-token (principal) (response bool uint))
        (remove-dividend-token (principal) (response bool uint))
        (freeze-token (principal) (response bool uint))
        
        ;; Token queries
        (is-registered (principal) (response bool uint))
        (is-frozen (principal) (response bool uint))
        (get-token-details (principal) (response {
            registered-height: uint,
            last-distribution: uint,
            frozen: bool,
            total-distributed: uint
        } uint))
        
        ;; Registry management
        (get-registered-token-count () (response uint uint))
        (is-registry-full () (response bool uint))
        
        ;; Guardian functions
        (set-registry-guardian (principal) (response bool uint))
        (validate-registry-state () (response bool uint))
    )
)

;; ========================================
;; Helper Functions
;; ========================================

;; Validates distribution parameters with rate limiting
(define-public (example-validate-distribution (amount uint) (height uint))
    (begin
        ;; Basic validation
        (asserts! (>= amount MIN_DISTRIBUTION_AMOUNT)
            ERR_BELOW_MINIMUM_AMOUNT)
        (asserts! (> height block-height)
            ERR_INVALID_HEIGHT)
        (asserts! (> (- height block-height) MIN_DISTRIBUTION_INTERVAL)
            ERR_DISTRIBUTION_TOO_FREQUENT)
            
        ;; Rate limiting
        (asserts! (<= (/ (* amount PRECISION_FACTOR) height) MAX_DIVIDEND_RATE)
            ERR_EXCEEDS_MAX_RATE)
            
        (ok true)))

;; Registry capacity check with additional validation
(define-read-only (example-check-registry-capacity (current-count uint))
    (begin
        (asserts! (< current-count MAX_REGISTERED_TOKENS)
            ERR_REGISTRY_FULL)
        (ok true)))

;; Maximum uint value (u340282366920938463463374607431768211455)
(define-constant MAX_UINT u340282366920938463463374607431768211455)

;; Precision handling with overflow protection
(define-read-only (scale-amount (amount uint))
    (begin
        (asserts! (<= amount (/ MAX_UINT PRECISION_FACTOR))
            ERR_ARITHMETIC_ERROR)
        (ok (* amount PRECISION_FACTOR))))