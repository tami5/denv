(import sh)

(defn run
  `Wrapper around janet-sh.`
  [args &opt sudo echo]

  (let [buf @""
        echo (default echo true)
        status (cond
                 (and (string? sudo) echo)
                 (sh/run* [;args :> buf :> [stderr stdout] :< sudo])
                 (and (string? sudo) (not echo))
                 (sh/run* ["/usr/bin/sudo" "-S" ;args :>
                           buf :> [stderr stdout] :< sudo])
                 :else (sh/run* [;args :> buf :> [stderr stdout]]))]
    {:succ (all zero? status)
     :out (-> buf string/slice string/trimr)}))
