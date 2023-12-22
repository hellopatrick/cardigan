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
