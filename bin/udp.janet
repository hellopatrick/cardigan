(def listen-addr (os/getenv "LISTEN_ADDR" "localhost"))

(def udp-server (net/listen listen-addr "8080" :datagram))

(defn run-server [{:server server :ch ch}]
  (def db @{})

  (forever
   (def [who msg] (ev/take ch))
   (def res (string/split "=" msg 0 2))
   (pp res)
   (match res
     ["version" _] '()
     ["version"] (:send-to server who "version=udp-server 2.0\n")
     [key value] (put db key value)
     [key] (:send-to server who (string/format "%s=%s\n" key (get db key ""))))))

(def server-ch (ev/chan))

(ev/go run-server {:server udp-server :ch server-ch})

(forever
 (def buf @"")
 (def who (:recv-from udp-server 1024 buf))
 (ev/give server-ch [who (string/trim buf)]))
