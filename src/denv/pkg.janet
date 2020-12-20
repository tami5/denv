(use src/denv/core)
(use src/denv/util/print)
(import src/denv/util/fs)
(import src/denv/util/sh)

# TODO: make it accept a table of package definition and use in logs
(def- supported-pm
  (case distro
    :archlinux
    {:cmd (cond
            (= "yay" (get-in cfg [:user/pm :archlinux])) "yay"
            (= "paru" (get-in cfg [:user/pm :archlinux])) "paru"
            :else "paru")
     :options ["--noconfirm" "--sudoloop"]
     :add "-S"
     :update "-S"
     :remove "-Rs"
     :check "-Q"}
    :mac
    {:cmd "brew"
     :options []
     :add "install"
     :remove "unistall"
     :update "upgrade"
     :info "check"}))

(def- actions
    (let [a supported-pm
          cmd (a :cmd)
          options (a :options) ]
      {:add [cmd (a :add) ;options]
       :remove [cmd (a :remove) ;options]
       :update [cmd (a :update) ;options]
       :check [cmd (a :check) ;options]}))

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

