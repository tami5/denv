(use src/denv/core)
(import src/denv/util/fs)
(import src/denv/util/sh)

(def- actions
  (case distro
    :archlinux
    (let [main "/usr/bin/pacman"
          nonconf "--noconfirm"]
      {:add [main "-S" nonconf]
       :remove [main "-R" nonconf]
       :update [main "-S" nonconf]
       :check [main "-Q" nonconf]})
    :mac
    (let [main "brew"]
      {:add [main "install"]
       :remove [main "uninstall"]
       :update [main "upgrade"]
       :info [main "check"]})))

(def- msgs
  {:err {:add "Failed to install '%s'."
         :remove "Failed to remove '%s'"
         :update "Failed to update '%s'"}

   :succ {:remove "Removed '%s'"
          :add "Installed '%s'"
          :update "Updated '%s'"}})

(defn exists? [pkg]
  (sh/run (flatten [(actions :check) pkg])))


(defn- exit
  ```
  Post function used after "run" to update-logs and print msg to the user.
  ```
  [act pkg res print?]
  (if (not (res :succ))
    (let [msg (string/format (get-in msgs [:err act]) pkg)]
      (printf (cerr "%s\n ERR: %s") msg (res :out)))
    (let [msg (string/format (get-in msgs [:succ act]) pkg)]
      (update-registry :pkg @{:pkg/name pkg :action act})
      (when print? (print (csucc msg))))))

(defn req
  ```
  run an action on a pkg.
  ```
  [act pkg &opt print?]
  (let [pkg (if (string? pkg) pkg
              (string/join pkg " "))
        args (flatten [(actions act) pkg])
        res (if (= distro :archlinux)
              (sh/run args (cfg :user/pass))
              (sh/run args))
        print? (default print? true)]
    (exit act pkg res print?)))

