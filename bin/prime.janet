(use spork)
(use ../cardigan/math)

(defn read-until
  "reads all the bytes until the delim is seen."
  [connection delim]
  (var seen? false)
  (var buf (buffer/new 256))
  (while (not seen?)
    (def current-value (ev/read connection 1))
    (when (= current-value nil) (break))
    (buffer/push buf current-value)
    (set seen? (deep= current-value delim)))
  (if seen? buf nil))

(defn process-req
  ""
  [req]
  (match req 
    ({"method" "isPrime" "number" n} (number? n)) {"method" "isPrime" "prime" (is-prime? n)} 
    _ {"error" "invalid request"}))

(defn handler
  [conn]
  (defer (:close conn)
         (forever
          (def msg (read-until conn @"\n"))
          (when (nil? msg) (break))
          (def req (json/decode msg))
          (def res (process-req req)) 
          (ev/write conn (json/encode res))
          (ev/write conn @"\n"))))

(def listen-addr (os/getenv "LISTEN_ADDR" "localhost"))

(net/server listen-addr "8080"
            (fn [connection]
              (ev/call handler connection)))
