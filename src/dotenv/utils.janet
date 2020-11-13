(import sh)

# TODO: implement macos version 
(defn notify
  "Send a notification message handled by notify-send 
  in linux and alerter in macos"
  [&keys {:title title :subtitle subtitle :timeout timeout}]
  (let [timeout (or timeout 10000)
        subtitle (or subtitle "")]
    (if (= (os/which) :linux)
      (sh/$? notify-send ,title ,subtitle -t ,timeout))))

# thanks to @ahungry
(def file->config (comp parse slurp))

(defn config [key] 
  (get-in (file->config "env.janet") key))



