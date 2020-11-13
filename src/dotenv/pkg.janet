# Pkg management module
(import sh)
(import "src/dotenv/utils")

(defn cmd [action pkg-name]
  "Given an action and pkg-name, 
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
    (if (string? pkg-name)
      [(pm :main) (pm :flag) (pm action) pkg-name]
      (flatten [(pm :main) (pm :flag) (pm action) pkg-name]))))


(defn- notify 
  "Send OS notification based on `status`, with a message that matches 
  the `action` ran, and including the `pkg-name`"
  [status action pkg-name]
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
           :subtitle (string/format (msg :succ) pkg-name)
           :timeout 3000}
          {:title "Error:"
           :subtitle (string/format (msg :err) pkg-name)
           :timeout 50000})]
    (utils/notify 
      :title (args :title)
      :subtitle (args :subtitle))))

(defn- run! 
  "Given an action and pkg-name run the command. If silent, 
   don't notify the user with the result."
  [action pkg-name &opt silent] 
  (let [sudo (if (= (os/which) :linux) true false) 
        head (if sudo ["/usr/bin/sudo" "-S"])
        exec (if (not (nil? head))
               (sh/$? echo ,(utils/config [:pass]) | ;(flatten [head ;(cmd action pkg-name)]))
               (sh/$? ;(cmd action pkg-name)))
        res (if silent
              exec
              (notify exec action pkg-name))] res))

(defn- log 
  "Log chanages in the current os. Used in add!, 
   remove! to keep track of new and removed pkgs."
  [action pkg-name])

(defn add!
  "Given a pkg, install it."
  [pkg-name &opt silent]
  (run! :add pkg-name silent))

(defn remove!
  "Given a pkg, remove! it"
  [pkg-name &opt silent]
  (run! :remove pkg-name silent))

(defn upgrade! 
  "Given a pkg, upgrade."
  [pkg-name &opt silent]
  (run! :upgrade pkg-name silent))

(defn ensure!
  "if `pkg-name` isn't installed install it,
  otherwise if `force`, removed it and reinstall it."
  [pkg-name &opt force]
  (if force
    (do (run! :remove pkg-name) 
      (run! :add pkg-name))
    (when (not (run! :check pkg-name true))
      (run! :add pkg-name))))
