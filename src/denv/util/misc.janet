(defn datetime
  ```
  Returns a formated string of the current data and time.
  ```
  []
  (let [date (os/date (os/time) true)
        f (fn [d] (string/slice (string "0" d) -3))
        Y (date :year)
        M (f (inc (date :month)))
        d (f (date :month-day))
        h (f (date :hours))
        m (f (date :minutes))]
    (string Y "-" M "-" d "-" h ":" m)))
