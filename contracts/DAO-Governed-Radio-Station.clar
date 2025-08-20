(define-constant ERR-NOT-MEMBER (err u100))
(define-constant ERR-ALREADY-MEMBER (err u101))
(define-constant ERR-NOT-OWNER (err u102))
(define-constant ERR-PLAYLIST-NOT-FOUND (err u103))
(define-constant ERR-ALREADY-VOTED (err u104))
(define-constant ERR-VOTING-CLOSED (err u105))
(define-constant ERR-INSUFFICIENT-STAKE (err u106))

(define-data-var contract-owner principal tx-sender)
(define-data-var minimum-stake uint u1000000)
(define-data-var voting-period uint u144)
(define-data-var playlist-counter uint u0)

(define-map members principal
  {
    stake: uint,
    joined-at: uint,
    reputation: uint
  })

(define-map playlists uint
  {
    name: (string-ascii 64),
    creator: principal,
    songs: (list 20 (string-ascii 128)),
    votes-for: uint,
    votes-against: uint,
    created-at: uint,
    voting-ends: uint,
    status: (string-ascii 16)
  })

(define-map playlist-votes {playlist-id: uint, voter: principal} bool)

(define-read-only (get-contract-owner)
  (var-get contract-owner))

(define-read-only (get-minimum-stake)
  (var-get minimum-stake))

(define-read-only (get-voting-period)
  (var-get voting-period))

(define-read-only (get-member (user principal))
  (map-get? members user))

(define-read-only (is-member (user principal))
  (is-some (map-get? members user)))

(define-read-only (get-playlist (playlist-id uint))
  (map-get? playlists playlist-id))

(define-read-only (get-playlist-vote (playlist-id uint) (voter principal))
  (map-get? playlist-votes {playlist-id: playlist-id, voter: voter}))

(define-read-only (get-total-playlists)
  (var-get playlist-counter))

(define-public (join-dao)
  (let ((current-block stacks-block-height))
    (if (is-member tx-sender)
      ERR-ALREADY-MEMBER
      (if (>= (stx-get-balance tx-sender) (var-get minimum-stake))
        (begin
          (try! (stx-transfer? (var-get minimum-stake) tx-sender (as-contract tx-sender)))
          (map-set members tx-sender
            {
              stake: (var-get minimum-stake),
              joined-at: current-block,
              reputation: u0
            })
          (ok true))
        ERR-INSUFFICIENT-STAKE))))

(define-public (leave-dao)
  (let ((member-data (unwrap! (get-member tx-sender) ERR-NOT-MEMBER)))
    (begin
      (try! (as-contract (stx-transfer? (get stake member-data) tx-sender tx-sender)))
      (map-delete members tx-sender)
      (ok true))))

(define-public (create-playlist (name (string-ascii 64)) (songs (list 20 (string-ascii 128))))
  (let 
    ((current-block stacks-block-height)
     (playlist-id (+ (var-get playlist-counter) u1)))
    (if (not (is-member tx-sender))
      ERR-NOT-MEMBER
      (begin
        (map-set playlists playlist-id
          {
            name: name,
            creator: tx-sender,
            songs: songs,
            votes-for: u0,
            votes-against: u0,
            created-at: current-block,
            voting-ends: (+ current-block (var-get voting-period)),
            status: "active"
          })
        (var-set playlist-counter playlist-id)
        (ok playlist-id)))))

(define-public (vote-on-playlist (playlist-id uint) (vote-for bool))
  (let 
    ((playlist-data (unwrap! (get-playlist playlist-id) ERR-PLAYLIST-NOT-FOUND))
     (current-block stacks-block-height)
     (vote-key {playlist-id: playlist-id, voter: tx-sender}))
    (if (not (is-member tx-sender))
      ERR-NOT-MEMBER
      (if (is-some (get-playlist-vote playlist-id tx-sender))
        ERR-ALREADY-VOTED
        (if (> current-block (get voting-ends playlist-data))
          ERR-VOTING-CLOSED
          (begin
            (map-set playlist-votes vote-key vote-for)
            (if vote-for
              (map-set playlists playlist-id
                (merge playlist-data {votes-for: (+ (get votes-for playlist-data) u1)}))
              (map-set playlists playlist-id
                (merge playlist-data {votes-against: (+ (get votes-against playlist-data) u1)})))
            (ok true)))))))

(define-public (finalize-playlist (playlist-id uint))
  (let 
    ((playlist-data (unwrap! (get-playlist playlist-id) ERR-PLAYLIST-NOT-FOUND))
     (current-block stacks-block-height))
    (if (not (is-member tx-sender))
      ERR-NOT-MEMBER
      (if (<= current-block (get voting-ends playlist-data))
        ERR-VOTING-CLOSED
        (let ((new-status (if (> (get votes-for playlist-data) (get votes-against playlist-data)) "approved" "rejected")))
          (begin
            (map-set playlists playlist-id
              (merge playlist-data {status: new-status}))
            (if (is-eq new-status "approved")
              (begin
                (let ((creator-data (unwrap! (get-member (get creator playlist-data)) ERR-NOT-MEMBER)))
                  (map-set members (get creator playlist-data)
                    (merge creator-data {reputation: (+ (get reputation creator-data) u10)})))
                (ok true))
              (ok true))))))))

(define-public (set-minimum-stake (new-stake uint))
  (if (is-eq tx-sender (var-get contract-owner))
    (begin
      (var-set minimum-stake new-stake)
      (ok true))
    ERR-NOT-OWNER))

(define-public (set-voting-period (new-period uint))
  (if (is-eq tx-sender (var-get contract-owner))
    (begin
      (var-set voting-period new-period)
      (ok true))
    ERR-NOT-OWNER))

(define-public (transfer-ownership (new-owner principal))
  (if (is-eq tx-sender (var-get contract-owner))
    (begin
      (var-set contract-owner new-owner)
      (ok true))
    ERR-NOT-OWNER))
