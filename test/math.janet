(use ../cardigan/math)

(def test-cases @{
                  1 false
                  2 true
                  3 true
                  13 true
                  15 false
                  21 false
                  109 true
                  65213 true
                  65214 false
})

(loop [[n expected] :pairs test-cases]
  (assert (= (is-prime? n) expected) (string/format "%d [expect=%v]" n expected)))
