# Pkg management module
(import sh)
(import "src/dotenv/utils")

(defn cmd [action pkg]
  "Given an action and pkg, 
   return the arguments to be executed."
  (let [pm (if (= (os/which) :linux) 
             {:main "/usr/bin/pacman"
              :add "-S"
              :flag  "--noconfirm"
              :remove "-R"
              :upgrade "-S"
              :check "-Q"} 
             {:main "brew"
              :add "install"
              :remove "uninstall"
              :flag  ""
              :upgrade "upgrade"
              :info "check"})] 
    (if (string? pkg)
      [(pm :main) (pm :flag) (pm action) pkg]
      (flatten [(pm :main) (pm :flag) (pm action) pkg]))))


(defn- notify 
  "Send OS notification based on `status`, with a message that matches 
  the `action` ran, and including the `pkg`"
  [status action pkg]
  (let [msg 
        (case action
          :remove 
          {:succ "`%s` has been removed!"
           :err  "For some reason %s could not be removed!!"}
          :add 
          {:succ "`%s` has been installed successfully!"
           :err  "For some reason `%s` could not be installed."}
          :upgrade 
          {:succ "`%s` has been updated successfully!"
           :err  "For some reason `%s` could not be updated."}
          :check 
          {:succ "`%s` is installed"
           :err  "`%s` isn't installed"})
        args 
        (if status 
          {:title "Succ:" 
           :subtitle (string/format (msg :succ) pkg)
           :timeout 3000}
          {:title "Error:"
           :subtitle (string/format (msg :err) pkg)
           :timeout 50000})]
    (utils/notify 
      :title (args :title)
      :subtitle (args :subtitle))))

(defn- run! 
  "Given an action and pkg run the command. If silent, 
   don't notify the user with the result."
  [action pkg &opt silent] 
  (let [sudo (if (= (os/which) :linux) true false) 
        head (if sudo ["/usr/bin/sudo" "-S"])
        exec (if (not (nil? head))
               (sh/$? echo ,(utils/user-config :pass) | ;(flatten [head ;(cmd action pkg)]))
        (sh/$? ;(cmd action pkg)))
        res (if silent
              exec
              (notify exec action pkg))] res))

(defn log!
  "Log chanages in the current os. Used in add!, 
   remove! to keep track of new and removed pkgs."
  [action pkg]
  (utils/log :pkg action pkg)
  (let [b (utils/ep utils/cache) 
        e utils/with-open
        i (string pkg "\n")
        f (fn [file] (e :a i (utils/ep (string b "/" file))))] 
    (cond 
      (= :add action) (f "new-pkgs.txt")
      (= :remove action) (f "removed-pkgs.txt")
      (= :upgrade action) (f "upgraded-pkgs.txt"))))

(defn add!
  "Given a pkg, install it."
  [pkg &opt silent]
  (run! :add pkg silent)
  (log! :add pkg))

(defn remove!
  "Given a pkg, remove! it"
  [pkg &opt silent]
  (run! :remove pkg silent)
  (log! :remove pkg))

(defn upgrade! 
  "Given a pkg, upgrade."
  [pkg &opt silent]
  (run! :upgrade pkg silent)
  (log! :upgrade pkg))

(defn ensure!
  "if `pkg` isn't installed install it,
  otherwise if `force`, removed it and reinstall it."
  [pkg &opt force]
  (if force
    (do (run! :remove pkg) 
      (run! :add pkg))
    (when (not (run! :check pkg true))
      (run! :add pkg))))
