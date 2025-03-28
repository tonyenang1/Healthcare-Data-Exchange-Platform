;; provider-verification.clar
;; Simple provider verification

(define-data-var admin principal tx-sender)

;; Simple map to track verified providers
(define-map verified-providers
  { provider: principal }
  { verified: bool }
)

;; Error codes
(define-constant ERR-NOT-AUTHORIZED u100)

;; Read-only functions
(define-read-only (is-verified (provider principal))
  (default-to false
    (get verified (map-get? verified-providers { provider: provider }))
  )
)

;; Public functions
(define-public (register-provider)
  (begin
    (map-set verified-providers
      { provider: tx-sender }
      { verified: false }
    )
    (ok true)
  )
)

;; Admin functions
(define-public (verify-provider (provider principal))
  (if (is-eq tx-sender (var-get admin))
    (begin
      (map-set verified-providers
        { provider: provider }
        { verified: true }
      )
      (ok true)
    )
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (revoke-verification (provider principal))
  (if (is-eq tx-sender (var-get admin))
    (begin
      (map-set verified-providers
        { provider: provider }
        { verified: false }
      )
      (ok true)
    )
    (err ERR-NOT-AUTHORIZED)
  )
)

(define-public (set-admin (new-admin principal))
  (if (is-eq tx-sender (var-get admin))
    (begin
      (var-set admin new-admin)
      (ok true)
    )
    (err ERR-NOT-AUTHORIZED)
  )
)

