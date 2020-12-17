(import sh)

(defn run
  `Wrapper around janet-sh.`
  [args &opt sudo]
  (let [buf @""
        status (if (not (string? sudo))
                 (sh/run* [;args :> buf :> [stderr stdout]])
                 (sh/run* ["/usr/bin/sudo" "-S" ;args :>
                           buf :> [stderr stdout] :< sudo]))]
    {:succ (all zero? status)
     :out (-> buf string/slice string/trimr)}))
