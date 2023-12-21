(defn le/to-int
  [& bytes]
  (reduce (fn [acc (i b)]
            (bor acc (blshift b (* i 8)))) 0 (pairs bytes)))

(defn be/to-int
  [& bytes]
  (le/to-int ;(reverse bytes)))
