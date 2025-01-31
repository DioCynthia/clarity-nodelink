;; NodeLink - P2P File Sharing Network

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-registered (err u100))
(define-constant err-already-registered (err u101))
(define-constant err-invalid-reputation (err u102))
(define-constant err-file-not-found (err u103))

;; Data structures
(define-map nodes 
  principal 
  {reputation: uint, active: bool, files: (list 100 uint)}
)

(define-map files
  uint
  {name: (string-ascii 64), 
   hash: (buff 32),
   size: uint,
   owner: principal,
   timestamp: uint,
   downloads: uint}
)

(define-data-var next-file-id uint u0)

;; Node registration
(define-public (register-node)
  (let ((sender tx-sender))
    (asserts! (is-none (map-get? nodes sender))
      err-already-registered)
    (ok (map-set nodes 
      sender
      {reputation: u0,
       active: true,
       files: (list)}))))

;; File sharing
(define-public (share-file (name (string-ascii 64)) 
                      (hash (buff 32))
                      (size uint))
  (let ((sender tx-sender)
        (file-id (var-get next-file-id)))
    (asserts! (is-some (map-get? nodes sender))
      err-not-registered)
    (map-set files file-id
      {name: name,
       hash: hash,
       size: size,
       owner: sender,
       timestamp: block-height,
       downloads: u0})
    (var-set next-file-id (+ file-id u1))
    (ok file-id)))

;; Download tracking
(define-public (record-download (file-id uint))
  (let ((file-data (unwrap! (map-get? files file-id)
                          err-file-not-found)))
    (ok (map-set files
      file-id
      (merge file-data
        {downloads: (+ (get downloads file-data) u1)})))))

;; Reputation system  
(define-public (update-reputation (node principal) (delta int))
  (let ((current-data (unwrap! (map-get? nodes node)
                            err-not-registered)))
    (asserts! (and (>= delta -10) (<= delta 10))
      err-invalid-reputation)
    (ok (map-set nodes 
      node
      (merge current-data
        {reputation: (to-uint (+ delta (default-to 0 (get reputation current-data))))})))))

;; Read-only functions
(define-read-only (get-node-info (node principal))
  (ok (map-get? nodes node)))

(define-read-only (get-file-info (file-id uint))
  (ok (map-get? files file-id)))
