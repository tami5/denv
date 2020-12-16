(import sh)
(import src/denv/util/fs)

(def distro
  (let [e? (fn [p] (fs/exists? p))]
    (cond
      (e? "/etc/lsb-release") :ubuntu
      (e? "/etc/debian_release") :debian
      (e? "/etc/arch-release") :archlinux
      (= "mac" (os/which)) :mac
      :else :unknown)))

(defn cmsg [t msg]
  (let [reset "\e[39;49m"]
    (case t
      :succ (string "\e[32m" msg reset) 
      :err  (string "\e[31m" msg reset) 
      :info (string "\e[33m" msg reset))))
(defn cinfo [msg] (cmsg :info msg))
(defn cerr [msg] (cmsg :err msg))
(defn csucc [msg] (cmsg :succ msg))

(def msgs 
  {:user-cfg-not-found (cerr "denv configuration file can't be found.")
   :denv-intro (cinfo "A simple configuration utility for managing complex setups.")})

(def cfg 
  (let [denv (fn [v] (-> v os/getenv (string "/denv") fs/ensure))
        cfg  (->> [(string (denv "XDG_DATA_HOME") "/config.janet")
                   (string (denv "XDG_CONFIG_HOME") "/config.janet")
                   (string (os/getenv "HOME") "/.denv/config.janet")
                   (string (os/cwd) "/env.janet")]
                  # TODO: return most recent one.
                  (filter fs/readable?)
                  (array/peek)) 
        user (if (nil? cfg) 
               (error (cerr :user-cfg-not-found))
               (-> cfg slurp parse))
        root (fn [&opt p]
               (string (os/getenv "HOME") "/" (user :path) 
                       (when p (string "/" p))))] 
    {:user/remote-repo (user :repo) 
     :user/local-repo (root) 
     :user/profiles (root (or (user :profiles) "profiles")) 
     :user/deps (root (or (user :deps) "local")) 
     :user/resources (root (or (user :resources) "store")) 
     :user/init (root (get-in user [:init distro])) 
     :user/pass (user :pass)
     :denv/notify (user :notify)
     :denv/cache-dir (denv "XDG_CACHE_HOME")  
     :denv/data-dir (denv "XDG_DATA_HOME") 
     :denv/debug (= 1 (os/getenv "DENV_DEBUG")) 
     :denv/deps-dir (fs/ensure (string (denv "XDG_DATA_HOME") "/deps"))
     :denv/log-dir (fs/ensure (string (denv "XDG_DATA_HOME") "/logs"))}))

(defn notify
  "Send a notification message handled by
  notify-send in linux and alerter in macos"
  [title &opt subtitle err timeout]
  (when (cfg :notify) 
    (let [timeout (or timeout 10000)
          subtitle (or subtitle "") 
          status (if err "critical" "normal")]
      (cond 
        # TODO: add case for macos
        # TODO: check against util
        (= (os/which) :linux) (sh/$ notify-send -u ,status ,title ,subtitle -t ,timeout)
        :else (error (string "denv notification doesn't support " (os/which)))))))

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
  "Append aspect, action and msg to denv log file."
  [aspect action msg]

  (def- path 
    (fs/ensure (string (cfg :denv/log-dir) 
                       "/os_state.log")))

  (def- input 
    (string/format 
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
        :upgrade "[UPDAT]") msg))
  (fs/with-open :a input path))
