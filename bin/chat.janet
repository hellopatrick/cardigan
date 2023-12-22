(use ../cardigan/ev)

(defn reject-conn
  [conn reason]
  (ev/write conn reason)
  (:close conn))

(defn handle-close
  [user]
  (printf "%s is leaving." user)
  (ev/give-supervisor :leave user))

(defn handle-client
  [user conn]
  (ev/give-supervisor :join user conn)
  (defer (handle-close user)
         (forever
          (def msg (read-until conn @"\n"))
          (if
            (nil? msg) (break)
            (ev/give-supervisor :message user (string/trim msg))))))

(defn accept-client
  [conn]
  (ev/write conn "Welcome to budgetchat! What shall I call you?\n")
  (def name (read-until conn @"\n"))

  (if-let [exists? (not (nil? name))
           long-enough? (> (length name) 1)
           acceptable? (not (nil? (peg/match ~(* (some (range "az" "AZ" "09")) "\n") name)))]
    (handle-client (string/trim name) conn)
    (reject-conn conn "invalid name")))

(defn current-users
  [users]
  (string/join (keys users) ", "))

(defn send-msg
  [conn msg]
  (ev/write conn msg)
  (ev/write conn "\n"))

(defn broadcast
  [users msg &opt &named origin]
  (loop [[user conn] :pairs users :when (not (= origin user))]
         (send-msg conn msg)))

(defn handle-join
  [users user conn]
  (send-msg conn (string "* The room contains: " (current-users users)))
  (broadcast users (string/format "* %s has entered the room" user))
  (put users user conn))

(defn handle-leave
  [users user]
  (if-let [conn (in users user)]
    (do 
      (:close conn)
      (put users user nil)
      (broadcast users (string/format "* %s has left the room" user)))))

(defn handle-message
  [users user msg]
  (broadcast users (string/format "[%s] %s" user msg) :origin user))

(defn handle-server-events
  [{:channel ch :users users}]
  (forever
   (match (ev/take ch)
     [:message user msg] (handle-message users user msg)
     [:join user conn] (handle-join users user conn)
     [:leave user] (handle-leave users user)
     [:ok f _] ()
     otherwise (printf "unhandled evt: %q" otherwise))))

(defn build-server
  [addr port]

  (def server-ch (ev/chan))
  (def server {:channel server-ch :users @{}})

  (ev/go handle-server-events server)

  (net/server addr port 
              (fn [conn] 
                (ev/go accept-client conn server-ch))))


(def listen-addr (os/getenv "LISTEN_ADDR" "localhost"))
(build-server listen-addr "8080")
