;; patient-consent.clar
;; Simple patient consent management

(define-data-var admin principal tx-sender)

;; Simple map to track consent
(define-map patient-consents
  { patient: principal, provider: principal }
  { active: bool }
)

;; Error codes
(define-constant ERR-NOT-AUTHORIZED u100)

;; Read-only functions
(define-read-only (has-consent (patient principal) (provider principal))
  (default-to false
    (get active (map-get? patient-consents { patient: patient, provider: provider }))
  )
)

;; Public functions
(define-public (grant-consent (provider principal))
  (begin
    (map-set patient-consents
      { patient: tx-sender, provider: provider }
      { active: true }
    )
    (ok true)
  )
)

(define-public (revoke-consent (provider principal))
  (begin
    (map-set patient-consents
      { patient: tx-sender, provider: provider }
      { active: false }
    )
    (ok true)
  )
)

;; Admin functions
(define-public (set-admin (new-admin principal))
  (if (is-eq tx-sender (var-get admin))
    (begin
      (var-set admin new-admin)
      (ok true)
    )
    (err ERR-NOT-AUTHORIZED)
  )
)
