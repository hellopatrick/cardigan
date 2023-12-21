(defn some? [x] (not (nil? x)))

(defn handler
  [connection]
  (defer (:close connection)
         (forever
          (def msg (ev/read connection 2048))
          (if (some? some?)
            (net/write connection msg)))))

(def listen-addr (os/getenv "LISTEN_ADDR" "localhost"))

(net/server listen-addr "8080"
            (fn [connection]
              (ev/call handler connection)))
