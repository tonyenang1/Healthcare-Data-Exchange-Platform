;; audit-trail.clar
;; Simple audit logging

(define-data-var admin principal tx-sender)
(define-data-var next-log-id uint u1)

;; Simple map for audit logs
(define-map audit-logs
  { log-id: uint }
  {
    record-id: uint,
    accessor: principal,
    timestamp: uint,
    success: bool
  }
)

;; Error codes
(define-constant ERR-NOT-AUTHORIZED u100)

;; Read-only functions
(define-read-only (get-log (log-id uint))
  (map-get? audit-logs { log-id: log-id })
)

;; Public functions
(define-public (log-access (record-id uint) (success bool))
  (let ((log-id (var-get next-log-id)))
    (begin
      (map-set audit-logs
        { log-id: log-id }
        {
          record-id: record-id,
          accessor: tx-sender,
          timestamp: block-height,
          success: success
        }
      )
      (var-set next-log-id (+ log-id u1))
      (ok log-id)
    )
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

