;; BioGrid Behavioral Utilities Blockchain Smart Contract

;; Error Constants
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_INVALID_BEHAVIORAL_SCORE (err u101))
(define-constant ERR_INSUFFICIENT_STAKE (err u102))
(define-constant ERR_UTILITY_ACCESS_DENIED (err u103))
(define-constant ERR_FRAUDULENT_PATTERN_DETECTED (err u104))
(define-constant ERR_EMERGENCY_PROTOCOL_ACTIVE (err u105))
(define-constant ERR_INVALID_CONSUMPTION_DATA (err u106))
(define-constant ERR_VALIDATOR_NOT_FOUND (err u107))
(define-constant ERR_INSUFFICIENT_TOKENS (err u108))
(define-constant ERR_UTILITY_TYPE_INVALID (err u109))
(define-constant ERR_BEHAVIORAL_VERIFICATION_FAILED (err u110))
(define-constant ERR_RATE_NEGOTIATION_FAILED (err u111))
(define-constant ERR_MARKETPLACE_TRANSACTION_FAILED (err u112))

;; Contract Variables
(define-data-var contract-owner principal tx-sender)
(define-data-var emergency-protocol-active bool false)
(define-data-var base-utility-rate uint u100)
(define-data-var fraud-detection-threshold uint u75)
(define-data-var min-validator-stake uint u1000)

;; User Behavioral Data
(define-map user-behavioral-profiles principal {
    behavioral-score: uint,
    consumption-rhythm: (list 24 uint),
    device-patterns: (list 10 uint),
    authenticity-rating: uint,
    last-verification: uint,
    fraud-flags: uint,
    utility-tokens: uint,
    energy-credits: uint
})

;; Utility Provider Registry
(define-map utility-providers principal {
    provider-type: (string-ascii 20),
    service-area: (string-ascii 50),
    base-rate: uint,
    renewable-capacity: uint,
    behavioral-compatibility: uint,
    reputation-score: uint
})

;; Validator Staking System
(define-map proof-of-consumption-validators principal {
    staked-amount: uint,
    accuracy-score: uint,
    validated-patterns: uint,
    prediction-success-rate: uint,
    last-validation: uint,
    validator-status: bool
})

;; Utility Access Control
(define-map utility-access-permissions principal {
    electricity: bool,
    water: bool,
    gas: bool,
    internet: bool,
    waste-management: bool,
    emergency-override: bool
})

;; Behavioral Signatures
(define-map behavioral-signatures principal {
    energy-signature: (buff 32),
    pattern-hash: (buff 32),
    verification-timestamp: uint,
    cross-utility-verified: bool,
    anomaly-score: uint
})

;; Consumption Analytics
(define-map consumption-analytics principal {
    daily-usage: (list 7 uint),
    peak-hours: (list 3 uint),
    efficiency-score: uint,
    predictability-index: uint,
    seasonal-adjustments: uint
})

;; Community Validators
(define-map community-validators principal {
    vouched-users: (list 10 principal),
    community-reputation: uint,
    emergency-validations: uint,
    validation-accuracy: uint
})

;; Utility Rate Negotiations
(define-map dynamic-utility-rates principal {
    current-rate: uint,
    behavioral-discount: uint,
    efficiency-bonus: uint,
    last-negotiation: uint,
    rate-lock-period: uint
})

;; Energy Marketplace Transactions
(define-map energy-marketplace-offers principal {
    renewable-credits: uint,
    asking-price: uint,
    behavioral-verification: bool,
    offer-expiry: uint,
    transaction-history: uint
})

;; Municipal Integration
(define-map municipal-services principal {
    street-lighting-access: bool,
    public-transport-verified: bool,
    civic-services-tier: uint,
    municipal-reputation: uint
})

;; Helper Functions
(define-private (get-current-time)
    block-height
)

(define-private (calculate-anomaly-score (consumption-data (list 24 uint)) (baseline-data (list 24 uint)))
    (let ((variance (fold calculate-variance consumption-data u0)))
        (if (> variance u50) u90 u10)
    )
)

(define-private (calculate-variance (item uint) (acc uint))
    (+ acc (if (> item u100) u10 u1))
)

(define-private (calculate-behavioral-discount (behavioral-score uint))
    (if (>= behavioral-score u90)
        u20
        (if (>= behavioral-score u70)
            u10
            u0
        )
    )
)

(define-private (calculate-efficiency-bonus (behavioral-score uint))
    (if (>= behavioral-score u95)
        u15
        (if (>= behavioral-score u80)
            u5
            u0
        )
    )
)

(define-private (verify-emergency-access (user principal))
    (let ((permissions (default-to 
            { electricity: false, water: false, gas: false, internet: false, 
              waste-management: false, emergency-override: false }
            (map-get? utility-access-permissions user))))
        (map-set utility-access-permissions user 
            (merge permissions { emergency-override: true }))
        true
    )
)

(define-private (update-utility-permissions (user principal) (utility-type (string-ascii 20)))
    (let ((permissions (default-to 
            { electricity: false, water: false, gas: false, internet: false, 
              waste-management: false, emergency-override: false }
            (map-get? utility-access-permissions user))))
        (if (is-eq utility-type "electricity")
            (map-set utility-access-permissions user (merge permissions { electricity: true }))
            (if (is-eq utility-type "water")
                (map-set utility-access-permissions user (merge permissions { water: true }))
                (if (is-eq utility-type "gas")
                    (map-set utility-access-permissions user (merge permissions { gas: true }))
                    (if (is-eq utility-type "internet")
                        (map-set utility-access-permissions user (merge permissions { internet: true }))
                        (map-set utility-access-permissions user (merge permissions { waste-management: true }))
                    )
                )
            )
        )
        true
    )
)

;; Admin Functions
(define-public (set-contract-owner (new-owner principal))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
        (ok (var-set contract-owner new-owner))
    )
)

(define-public (activate-emergency-protocol)
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
        (ok (var-set emergency-protocol-active true))
    )
)

(define-public (deactivate-emergency-protocol)
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
        (ok (var-set emergency-protocol-active false))
    )
)

(define-public (update-fraud-threshold (new-threshold uint))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
        (asserts! (and (> new-threshold u0) (<= new-threshold u100)) ERR_INVALID_BEHAVIORAL_SCORE)
        (ok (var-set fraud-detection-threshold new-threshold))
    )
)

;; Core Public Functions
(define-public (register-behavioral-profile 
    (behavioral-score uint)
    (consumption-rhythm (list 24 uint))
    (device-patterns (list 10 uint)))
    (let ((current-time (get-current-time)))
        (asserts! (and (>= behavioral-score u1) (<= behavioral-score u100)) ERR_INVALID_BEHAVIORAL_SCORE)
        (asserts! (> (len consumption-rhythm) u0) ERR_INVALID_CONSUMPTION_DATA)
        (map-set user-behavioral-profiles tx-sender {
            behavioral-score: behavioral-score,
            consumption-rhythm: consumption-rhythm,
            device-patterns: device-patterns,
            authenticity-rating: behavioral-score,
            last-verification: current-time,
            fraud-flags: u0,
            utility-tokens: u100,
            energy-credits: u0
        })
        (ok true)
    )
)

(define-public (verify-utility-access (utility-type (string-ascii 20)))
    (let (
        (user-profile (unwrap! (map-get? user-behavioral-profiles tx-sender) ERR_UTILITY_ACCESS_DENIED))
        (behavioral-score (get behavioral-score user-profile))
        (fraud-flags (get fraud-flags user-profile))
    )
        (asserts! (>= behavioral-score u50) ERR_BEHAVIORAL_VERIFICATION_FAILED)
        (asserts! (< fraud-flags u3) ERR_FRAUDULENT_PATTERN_DETECTED)
        (if (var-get emergency-protocol-active)
            (ok (verify-emergency-access tx-sender))
            (ok (update-utility-permissions tx-sender utility-type))
        )
    )
)

(define-public (stake-as-validator (stake-amount uint))
    (begin
        (asserts! (>= stake-amount (var-get min-validator-stake)) ERR_INSUFFICIENT_STAKE)
        (map-set proof-of-consumption-validators tx-sender {
            staked-amount: stake-amount,
            accuracy-score: u100,
            validated-patterns: u0,
            prediction-success-rate: u100,
            last-validation: (get-current-time),
            validator-status: true
        })
        (ok true)
    )
)

(define-public (detect-anomalous-consumption 
    (user principal)
    (consumption-data (list 24 uint))
    (baseline-data (list 24 uint)))
    (let (
        (anomaly-score (calculate-anomaly-score consumption-data baseline-data))
        (fraud-threshold (var-get fraud-detection-threshold))
        (user-profile (unwrap! (map-get? user-behavioral-profiles user) ERR_UTILITY_ACCESS_DENIED))
    )
        (if (> anomaly-score fraud-threshold)
            (begin
                (map-set user-behavioral-profiles user 
                    (merge user-profile { fraud-flags: (+ (get fraud-flags user-profile) u1) }))
                (ok { fraud-detected: true, anomaly-score: anomaly-score })
            )
            (ok { fraud-detected: false, anomaly-score: anomaly-score })
        )
    )
)

(define-public (negotiate-dynamic-rate)
    (let (
        (user-profile (unwrap! (map-get? user-behavioral-profiles tx-sender) ERR_UTILITY_ACCESS_DENIED))
        (behavioral-score (get behavioral-score user-profile))
        (base-rate (var-get base-utility-rate))
        (discount (calculate-behavioral-discount behavioral-score))
        (current-time (get-current-time))
    )
        (asserts! (>= behavioral-score u60) ERR_RATE_NEGOTIATION_FAILED)
        (map-set dynamic-utility-rates tx-sender {
            current-rate: (- base-rate discount),
            behavioral-discount: discount,
            efficiency-bonus: (calculate-efficiency-bonus behavioral-score),
            last-negotiation: current-time,
            rate-lock-period: u86400
        })
        (ok (- base-rate discount))
    )
)

(define-public (trade-energy-credits 
    (credits-amount uint)
    (asking-price uint)
    (buyer principal))
    (let (
        (seller-profile (unwrap! (map-get? user-behavioral-profiles tx-sender) ERR_UTILITY_ACCESS_DENIED))
        (buyer-profile (unwrap! (map-get? user-behavioral-profiles buyer) ERR_UTILITY_ACCESS_DENIED))
        (seller-credits (get energy-credits seller-profile))
        (buyer-tokens (get utility-tokens buyer-profile))
    )
        (asserts! (>= seller-credits credits-amount) ERR_INSUFFICIENT_TOKENS)
        (asserts! (>= buyer-tokens asking-price) ERR_INSUFFICIENT_TOKENS)
        (asserts! (>= (get behavioral-score seller-profile) u70) ERR_BEHAVIORAL_VERIFICATION_FAILED)
        
        ;; Transfer credits and tokens
        (map-set user-behavioral-profiles tx-sender 
            (merge seller-profile { 
                energy-credits: (- seller-credits credits-amount),
                utility-tokens: (+ (get utility-tokens seller-profile) asking-price)
            }))
        (map-set user-behavioral-profiles buyer 
            (merge buyer-profile { 
                energy-credits: (+ (get energy-credits buyer-profile) credits-amount),
                utility-tokens: (- buyer-tokens asking-price)
            }))
        
        (ok { transaction-completed: true, credits-transferred: credits-amount, price-paid: asking-price })
    )
)

(define-public (register-utility-provider 
    (provider-type (string-ascii 20))
    (service-area (string-ascii 50))
    (base-rate uint)
    (renewable-capacity uint))
    (begin
        (map-set utility-providers tx-sender {
            provider-type: provider-type,
            service-area: service-area,
            base-rate: base-rate,
            renewable-capacity: renewable-capacity,
            behavioral-compatibility: u100,
            reputation-score: u100
        })
        (ok true)
    )
)

(define-public (create-energy-marketplace-offer 
    (renewable-credits uint)
    (asking-price uint)
    (expiry-hours uint))
    (let ((current-time (get-current-time)))
        (asserts! (> renewable-credits u0) ERR_INSUFFICIENT_TOKENS)
        (asserts! (> asking-price u0) ERR_MARKETPLACE_TRANSACTION_FAILED)
        (map-set energy-marketplace-offers tx-sender {
            renewable-credits: renewable-credits,
            asking-price: asking-price,
            behavioral-verification: true,
            offer-expiry: (+ current-time (* expiry-hours u3600)),
            transaction-history: u0
        })
        (ok true)
    )
)

;; Read-Only Functions
(define-read-only (get-behavioral-score (user principal))
    (match (map-get? user-behavioral-profiles user)
        user-profile (ok (get behavioral-score user-profile))
        ERR_UTILITY_ACCESS_DENIED
    )
)

(define-read-only (get-utility-permissions (user principal))
    (match (map-get? utility-access-permissions user)
        permissions (ok permissions)
        ERR_UTILITY_ACCESS_DENIED
    )
)

(define-read-only (get-validator-info (validator principal))
    (match (map-get? proof-of-consumption-validators validator)
        validator-info (ok validator-info)
        ERR_VALIDATOR_NOT_FOUND
    )
)

(define-read-only (get-consumption-analytics (user principal))
    (match (map-get? consumption-analytics user)
        analytics (ok analytics)
        ERR_UTILITY_ACCESS_DENIED
    )
)

(define-read-only (get-dynamic-rate (user principal))
    (match (map-get? dynamic-utility-rates user)
        rate-info (ok rate-info)
        ERR_UTILITY_ACCESS_DENIED
    )
)

(define-read-only (get-marketplace-offer (seller principal))
    (match (map-get? energy-marketplace-offers seller)
        offer-info (ok offer-info)
        ERR_MARKETPLACE_TRANSACTION_FAILED
    )
)

(define-read-only (get-contract-info)
    (ok {
        owner: (var-get contract-owner),
        emergency-active: (var-get emergency-protocol-active),
        base-rate: (var-get base-utility-rate),
        fraud-threshold: (var-get fraud-detection-threshold),
        min-stake: (var-get min-validator-stake)
    })
)

(define-read-only (get-user-profile (user principal))
    (match (map-get? user-behavioral-profiles user)
        profile (ok profile)
        ERR_UTILITY_ACCESS_DENIED
    )
)