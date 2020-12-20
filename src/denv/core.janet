(import src/denv/util/fs)
(use src/denv/util/print)
(use src/denv/util/misc)
(def denv-version "0.1") # TODO: read from a file e.g. doc/version.

(def distro
  (let [e? (fn [p] (fs/exists? p))]
    (cond
      (e? "/etc/lsb-release") :ubuntu
      (e? "/etc/debian_release") :debian
      (e? "/etc/arch-release") :archlinux
      (= "mac" (os/which)) :mac
      :else :unknown)))

(def cfg
  # TODO: make each value a def, check for config file at the beginning of the file.
  #       Or split to user/denv vars
  (let [denv (fn [v] (-> v os/getenv (string "/denv") fs/ensure))
        cfg  (->> [(string (denv "XDG_DATA_HOME") "/config.janet")
                   (string (denv "XDG_CONFIG_HOME") "/config.janet")
                   (string (os/getenv "HOME") "/.denv/config.janet")
                   (string (os/cwd) "/env.janet")]
                  # TODO: return most recent one.
                  (filter fs/readable?)
                  (array/peek))
        user (if (nil? cfg)
               (error (cerr "denv configuration file can't be found."))
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
     :user/distro distro
     :denv/upstream "https://github.com/tami5/denv"
     :denv/cache-dir (denv "XDG_CACHE_HOME")
     :denv/data-dir (denv "XDG_DATA_HOME")
     :denv/debug (= 1 (os/getenv "DENV_DEBUG"))
     :denv/deps (fs/ensure (string (denv "XDG_DATA_HOME") "/deps"))
     :denv/log (fs/ensure (string (denv "XDG_DATA_HOME") "/logs"))
     :denv/version denv-version}))

(defn update-registry
  ```
  Post function used after "req" to update logs and print msg to the user.
  # TODO: sort logs/use array
  ```
  [aspect xs]
  (def- path (string/format "%s/%ss.janet" (cfg :denv/log) (string aspect)))
  (def- content (slurp (fs/ensure path)))
  (def- logged (if (not (empty? content)) (parse content) @{}))
  (put logged (keyword (datetime)) xs)
  (spit path (string/format "%m" logged)))
