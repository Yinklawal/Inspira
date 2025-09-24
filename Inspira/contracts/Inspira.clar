;; ArtVault: Creative Community Reputation System
;; A decentralized platform for tracking artistic contributions and creativity

;; Error codes
(define-constant gallery-owner tx-sender)
(define-constant err-owner-access (err u100))
(define-constant err-artist-not-found (err u101))
(define-constant err-forbidden (err u102))
(define-constant err-artist-registered (err u103))
(define-constant err-portfolio-missing (err u104))
(define-constant err-invalid-medium (err u105))
(define-constant err-invalid-params (err u106))

;; Creative mediums supported
(define-data-var art-mediums (list 3 (string-ascii 24)) (list "creation" "review" "collaboration"))

;; Artist portfolio tracking
(define-map artist-portfolio 
    principal 
    {
        creativity-score: uint,
        artworks-created: uint,
        reviews-given: uint,
        last-creation: uint,
        collaborations: uint
    }
)
(define-map medium-values
    {medium: (string-ascii 24)}
    {inspiration: uint}
)

;; Set default inspiration values
(map-set medium-values {medium: "creation"} {inspiration: u10})
(map-set medium-values {medium: "review"} {inspiration: u5})
(map-set medium-values {medium: "collaboration"} {inspiration: u15})

;; Validation helpers
(define-private (is-valid-medium (medium-type (string-ascii 24)))
    (is-some (index-of (var-get art-mediums) medium-type))
)

;; Public functions
(define-public (register-artist)
    (begin
        (asserts! (is-none (get-artist-portfolio tx-sender)) err-artist-registered)
        (ok (map-set artist-portfolio tx-sender {
            creativity-score: u0,
            artworks-created: u0,
            reviews-given: u0,
            last-creation: stacks-block-height,
            collaborations: u0
        }))
    )
)

(define-public (submit-artwork)
    (let (
        (portfolio (unwrap! (get-artist-portfolio tx-sender) err-portfolio-missing))
        (inspire (get inspiration (unwrap! (map-get? medium-values {medium: "creation"}) err-invalid-medium)))
    )
    (ok (map-set artist-portfolio tx-sender (merge portfolio {
        creativity-score: (+ (get creativity-score portfolio) inspire),
        artworks-created: (+ (get artworks-created portfolio) u1),
        last-creation: stacks-block-height
    })))
    )
)

(define-public (provide-review)
    (let (
        (portfolio (unwrap! (get-artist-portfolio tx-sender) err-portfolio-missing))
        (inspire (get inspiration (unwrap! (map-get? medium-values {medium: "review"}) err-invalid-medium)))
    )
    (ok (map-set artist-portfolio tx-sender (merge portfolio {
        creativity-score: (+ (get creativity-score portfolio) inspire),
        reviews-given: (+ (get reviews-given portfolio) u1),
        last-creation: stacks-block-height
    })))
    )
)

(define-public (join-collaboration)
    (let (
        (portfolio (unwrap! (get-artist-portfolio tx-sender) err-portfolio-missing))
        (inspire (get inspiration (unwrap! (map-get? medium-values {medium: "collaboration"}) err-invalid-medium)))
    )
    (ok (map-set artist-portfolio tx-sender (merge portfolio {
        creativity-score: (+ (get creativity-score portfolio) inspire),
        collaborations: (+ (get collaborations portfolio) u1),
        last-creation: stacks-block-height
    })))
    )
)

;; Admin functions
(define-public (update-medium-value (medium-type (string-ascii 24)) (new-inspire uint))
    (let
        (
            (max-inspire u1000)
            (validated-inspire (if (> new-inspire max-inspire) max-inspire new-inspire))
        )
        (begin
            (asserts! (is-eq tx-sender gallery-owner) err-owner-access)
            (asserts! (is-valid-medium medium-type) err-invalid-medium)
            (ok (map-set medium-values {medium: medium-type} {inspiration: validated-inspire}))
        )
    )
)

;; Read-only functions
(define-read-only (get-artist-portfolio (artist principal))
    (map-get? artist-portfolio artist)
)

(define-read-only (get-medium-inspiration (medium-type (string-ascii 24)))
    (map-get? medium-values {medium: medium-type})
)

;; Private helper
(define-private (calculate-diminish (base uint) (interval uint))
    (let (
        (diminish-rate (/ interval u1000))
    )
    (if (> diminish-rate u0)
        (/ base diminish-rate)
        base
    ))
)

;; Active creativity calculation
(define-read-only (get-active-creativity (artist principal))
    (let (
        (portfolio (unwrap! (get-artist-portfolio artist) err-artist-not-found))
        (stagnation (- stacks-block-height (get last-creation portfolio)))
    )
    (ok (calculate-diminish (get creativity-score portfolio) stagnation))
    )
)