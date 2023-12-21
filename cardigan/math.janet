(defn is-prime?
  [n]
  (var prime? true)
  (cond
    (pos? (mod n 1)) (set prime? false)
    (<= n 1) (set prime? false)
    (= n 2) (set prime? true)
    (= 0 (mod n 2)) (set prime? false)
    (loop [i :range [3 n]
           :let [sqr (* i i)]
           :until (or (> sqr n) (not prime?))
           :when (= (mod n i) 0)]
      (set prime? false)))
  prime?)
