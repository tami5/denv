(use src/denv/core)
(use src/denv/util/print)
(import src/denv/util/fs)
(import src/denv/util/git)
(import src/denv/util/sh :as csh)

(def- msgs
  {:err {:esnure (cerr `Failed to install "%s".`)
         :remove (cerr `Failed to remove "%s".`)
         :update (cerr `Failed to update "%s".`)
         :sync (cerr `Failed to sync "%s".`)}

   :succ {:ensure (csucc `Installed "%s".`)
          :remove (csucc `Removed "%s".`)
          :update (csucc `Updated "%s".`)
          :sync (csucc `Synced "%s".`) }})

(defn- pre [dep]
  (let [link (git/repo-link (dep :repo))
        repo (git/user-repo (dep :repo))
        name (git/repo-name (dep :repo))
        path (if (dep :local)
               (string/format "%s/%s" (cfg :user/deps) name)
               # TODO should global dep path be user/repo-name?
               (string/format "%s/%s" (cfg :denv/deps) repo))]
    (merge dep
           {:name name
            :repo repo
            :path path
            :link link
            :local (if (nil? (dep :local)) false (dep :local))
            :disable (if (nil? (dep :disable)) false (dep :disable))
            :exists? (fs/dir? path)
            :ssh? (git/ssh-link? link)})))

(defn- post
  ```
  Post function used after "req" is handled.
  Mainly to update-logs and print msg to the user.
  ```
  [action i proc]
  (cond
    (true? (proc :succ))
    (do (printf (get-in msgs [:succ action]) (i :repo))
      (update-registry :dep
                       @{:repo (i :repo)
                         :desc (i :desc)
                         :path (i :path)
                         :ssh? (i :ssh?)
                         :action action}))
    (false? (proc :succ))
    (printf (string (get-in msgs [:err action])
                    "\nERR: %s") (i :repo) (proc :out))
    :else (printf (cerr "Couldn't run %s on %s.")
                  (i :repo))))

(defn req
  ```
  run an action on dep definition.
  ```
  [action dep]
  (def- i (pre dep))
  (case action
    :ensure (when (and (not (i :disable)) # TODO: return hash if package already exists.
                       (not (i :exists?)))
              # (printf (cinfo "Installing %s ...") (i :repo))
              (let [proc (git/clone (i :link) (i :path) (i :branch))]
                (post action i proc)))

    :update (if (and (not (git/up-to-date? (i :path))) (i :exists?))
              (let [proc (git/pull (i :path))]
                (post action i proc))
              (printf `"%s" is up-to-date` (i :repo)))

    :remove (cond
              (and (i :exists?) (not (i :remove)))
              (let [proc (csh/run ["rm" "-rf" (i :path)])]
                (post action i proc))
              (function? (i :remove))
              ((i :remove))) # TODO TEST

    :sync (if (and (i :exists?) (git/ssh? (i :path)))
            (git/sync (i :path))
            (printf (string (get-in msgs [:err :sync])
                            " ERR: Not ssh url.")
                    (i :repo)))

    :up-to-date? (git/up-to-date? (i :path))
    :unstaged-changes? (git/unstaged-changes? (i :path))
    :unpushed-commits? (git/unpushed-commits? (i :path))))

