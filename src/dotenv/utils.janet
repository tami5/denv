(import sh)
(import path)

(def user-config (-> (slurp "env.janet") parse))
(def cache (or (user-config :cache-dir) 
               (string (os/getenv "XDG_CACHE_HOME") "/dotenv")))

# TODO: implement macos version 
(defn notify
  "Send a notification message handled by
   notify-send in linux and alerter in macos"
  [&keys {:title title :subtitle subtitle :timeout timeout}]
  (let [timeout (or timeout 10000)
        subtitle (or subtitle "")]
    (if (= (os/which) :linux)
      (sh/$? notify-send ,title ,subtitle -t ,timeout))))


(defn ep 
  "Given a path of a file or a dir, ensure the file 
   or dir exists and return back the path"
  [path]
  (let [not-exists? (nil? (os/stat path))
        file? (string? (path/ext path))
        create (if file? (sh/$< touch ,path) (os/mkdir path))]
    (when not-exists? create) path))


(defn with-open 
  "Given a mode, string and a file, 
   write the string to the file."
  [mode str file]
  (let [f (file/open file mode)] 
    (file/write f str)
    (file/close f)))


(defn datetime
  "Returns a formated string of the current 
   data and time."
  []
  (let [date (os/date (os/time) true)
        f (fn [d] (string/slice (string "0" d) -3))
        Y (date :year)
        M (f (date :month))
        d (f (date :month-day))
        h (f (date :hours))
        m (f (date :minutes))]
    (string Y "-" M "-" d "-" h ":" m)))

(defn log 
  "Given an aspect, action and l (name or msg), 
  append activity to dotenv log file."
  [aspect action l]
  (let [input (string/format 
                "[%s] [%s] %s ['%s']\n" 
                (datetime)
                (string/ascii-upper (string aspect)) 
                (case action 
                  :remove "[REMOV]"
                  :add    "[ADDED]"
                  :clone  "[CLONE]"
                  :push   "[PUSHE]"
                  :ensure "[ENSUR]"
                  :pull   "[PULLE]"
                  :upgrade "[UPDAT]") l)
        path  (ep (string (ep cache) "/state.log"))]
    (with-open :a input path)))
