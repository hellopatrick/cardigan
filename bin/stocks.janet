(use ../cardigan/encoding)

(defn mk-request [req]
  (match req
    [73 t0 t1 t2 t3 p0 p1 p2 p3] {:type :insert :ts (be/to-int t0 t1 t2 t3) :price (be/to-int p0 p1 p2 p3)}
    [81 t0 t1 t2 t3 s0 s1 s2 s3] {:type :query :from (be/to-int t0 t1 t2 t3) :to (be/to-int s0 s1 s2 s3)}
    _ (error "sent invalid request")))

(defn between [x from to] (and (>= x from) (<= x to)))

(defn insert [prices ts p] (put prices ts p) nil)

(defn query [prices from to]
  (let [[cnt total] (reduce (fn
                              [(cnt total) (ts p)]
                              (if (between ts from to) [(inc cnt) (+ total p)] [cnt total]))
                            [0 0] (pairs prices))]
    (cond (zero? cnt) 0 (math/round (/ total cnt)))))

(defn process-request
  [{:prices prices} msg]
  (def req (mk-request msg))
  (match req
    {:type :insert :ts ts :price price} (insert prices ts price)
    {:type :query :from from :to to} (query prices from to)
    _ (error "unexpectedly invalid request")))

(defn process-response
  [conn v]
  (def msg (buffer/slice (int/to-bytes (int/s64 v) :be) 4 8))
  (ev/write conn msg))

(defn handler
  [conn]
  (def session {:prices @{}})
  (defer (:close conn)
         (forever
          (def chunk (ev/chunk conn 9))
          (when (nil? chunk) (break))
          (def msg (flatten chunk))
          (def res (process-request session msg))
          (if (not (nil? res)) (process-response conn res)))))

(def listen-addr (os/getenv "LISTEN_ADDR" "localhost"))

(net/server listen-addr "8080"
            (fn [conn] (ev/call handler conn)))
