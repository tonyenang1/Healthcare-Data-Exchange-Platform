;; record-access.clar
;; Simple record access control

(define-data-var admin principal tx-sender)
(define-data-var next-record-id uint u1)

;; Simple maps for records and access
(define-map medical-records
  { record-id: uint }
  {
    patient: principal,
    provider: principal
  }
)

(define-map record-access
  { record-id: uint, accessor: principal }
  { allowed: bool }
)

;; Error codes
(define-constant ERR-NOT-AUTHORIZED u100)
(define-constant ERR-NOT-FOUND u101)

;; Read-only functions
(define-read-only (can-access-record (record-id uint) (accessor principal))
  (default-to false
    (get allowed (map-get? record-access { record-id: record-id, accessor: accessor }))
  )
)

;; Public functions
(define-public (add-record (patient principal))
  (let ((record-id (var-get next-record-id)))
    (begin
      (map-set medical-records
        { record-id: record-id }
        {
          patient: patient,
          provider: tx-sender
        }
      )
      (var-set next-record-id (+ record-id u1))
      (ok record-id)
    )
  )
)

(define-public (grant-access (record-id uint) (accessor principal))
  (let ((record (map-get? medical-records { record-id: record-id })))
    (if (and (is-some record) (is-eq tx-sender (get patient (unwrap! record (err ERR-NOT-FOUND)))))
      (begin
        (map-set record-access
          { record-id: record-id, accessor: accessor }
          { allowed: true }
        )
        (ok true)
      )
      (err ERR-NOT-AUTHORIZED)
    )
  )
)

(define-public (revoke-access (record-id uint) (accessor principal))
  (let ((record (map-get? medical-records { record-id: record-id })))
    (if (and (is-some record) (is-eq tx-sender (get patient (unwrap! record (err ERR-NOT-FOUND)))))
      (begin
        (map-set record-access
          { record-id: record-id, accessor: accessor }
          { allowed: false }
        )
        (ok true)
      )
      (err ERR-NOT-AUTHORIZED)
    )
  )
)

