# Pkg management module
(import sh)
(use src/denv/core)
(import src/denv/util/fs)

(defn- pm-args [action package] 
  (let [pkg* (if (string? package) 
                package 
                ;package) 
        mang (case distro 
               :archlinux 
               (let [main "/usr/bin/pacman"
                     nonconf "--noconfirm"] 
                 {:add [main "-S" nonconf pkg*]
                  :remove [main "-R" nonconf pkg*] 
                  :upgrade [main "-S" nonconf pkg*]  
                  :check [main "-Q" nonconf pkg*]}) 
               :mac 
               (let [main "brew"]
                 {:add [main "install" pkg*]
                  :remove [main "uninstall" pkg*]
                  :upgrade [main "upgrade" pkg*]
                  :info [main "check" pkg*]}))]
    (cond 
      (not (= distro :archlinux)) [(mang action) :> :null]
      (= action :check) (mang :check)
      :else (do 
              (when (nil? (cfg :user/pass))
                (error 
                  (cerr "user password is not defined. It is required to install packages in arch")))    
              [@["echo" (cfg :user/pass)] (flatten [["/usr/bin/sudo" "-S"] (mang action) :> :null])]))))

(defn- exists? [pkg]
  (sh/$? ;(pm-args :check pkg)))

(defn- update-logs [action pkg]
  (let [path (fs/ensure (string (cfg :denv/log-dir) "/pkgs.janet" ))
        content (slurp path)
        pkgs (if (not (empty? content))
               (parse content)
               @{})]
    
    # TODO: sort logs/use array
    (put pkgs (keyword (datetime)) @{:pkg/name pkg :action action})
    (spit path (string/format "%m" pkgs))

    (log :pkg action pkg)))

(defn- post [action pkg status]  
  (def- msg 
    (case action
      :remove 
      (if status 
        "`%s` has been removed!"
        "For some reason %s couldn't be removed!!")

      :add 
      (if status 
        "`%s` has been installed successfully!"
        "For some reason `%s` couldn't be installed.")
      :upgrade 
      (if status
        "`%s` has been updated successfully!"
        "For some reason `%s` couldn't be updated.")))

  (if (not status)  
    (printf (cerr msg) pkg)
    (do (update-logs action pkg)
      (printf (cinfo msg) pkg))))

(defn run 
  "run an action on a pkg."
  [opts]   
  (let [action (opts :action)
        pkg (opts :pkg)
        cb (opts :cb)
        dry (or (opts :dry) false)
        silent (or (opts :silent) false)] 
    (def- args (pm-args action pkg))
    (if dry 
      args
      (let [status (all zero? (sh/run* ;args))] 
        (when (not silent) 
          (cb action pkg status))))))

(defn add
  "Given a pkg, install it."
  [pkg &opt dry]
  (run {:action :add 
        :pkg pkg 
        :cb post 
        :dry dry}))

(defn remove
  "Given a pkg, remove! it"
  [pkg &opt dry]
  (run {:action :remove
        :pkg pkg 
        :cb post 
        :dry dry}))

(defn upgrade 
  "Given a pkg, upgrade."
  [pkg &opt dry]
  (run {:action :upgrade
        :pkg pkg 
        :cb post 
        :dry dry}))

(defn ensure
  "if `pkg` isn't installed install it,
   otherwise if `force`, removed it and reinstall it."
  [pkg &opt force]
  (if force
    (do (run {:action :remove :pkg pkg :cb post :silent true}) 
      (run {:action :add :pkg pkg :cb post :silent true}))
    (when (not (exists? pkg))
      (add pkg))))
