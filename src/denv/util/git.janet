(import src/denv/util/sh :as csh)
(use src/denv/core) # FIXME: This shouldn't be called here. cfg
(use src/denv/util/misc)
(use src/denv/util/print)

(defn exec
  ```
  Execute action on "vals" passed.
  ```
  [action vals]
  (let [cmds {:clone "git clone %s %s --no-single-branch"
              :url "git -C %s config --get remote.origin.url"
              :clone-branch "git clone %s --branch %s --single-branch %s"
              :fetch "git -C %s fetch --depth 999999 --progress"
              :checkout "git -C %s checkout %s --"
              :branch-create "git -C %s checkout -b %s"
              :pull "git -C %s pull origin %s --progress --rebase=true"
              :branch "git -C %s rev-parse --abbrev-ref HEAD"
              :branch? "git -C %s show-ref refs/heads/%s"
              :push "git -C %s push -u origin %s"
              :status "git --git-dir=%s/.git --work-tree=%s diff --stat"
              :stage-all "git -C %s add ."}]
    (csh/run (string/split " " (string/format (cmds action) ;vals)))))

(defn branch-valid?
  `Is branch of dir valid?`
  [dir branch]
  ((exec :branch? [dir branch]) :succ))

(defn ssh?
  `Is repo URL SSH as opposed to https?`
  [path]
  (not (nil? (string/find "@git" ((exec :url [path]) :out)))))

(defn up-to-date?
  `Is local branch is up-to-date with remote?`
  [path] # TODO: use git status -sb instead.
  (empty? ((csh/run ["git" "-C" path "fetch" "--dry-run"]) :out)))

(defn unpushed-commits?
  `Is there unpublished local commits?`
  [path]
  (let [branch (get (exec :branch [path]) :out)
        res (csh/run ["git" "-C" path "log"
                      (string/format "origin/%s..%s" branch branch)])]
    (if (res :succ)
      (not (empty? (res :out)))
      (errorf (cerr "expected valid branch, got `%s`") branch))))

(defn unstaged-changes?
  `Is there unstaged local changes?`
  [path]
  (not (empty? (exec :status [path path]))))

(defn http-link?
  ```
  Is "str" a git http/https link?
  ```
  [str]
  (-> (peg/match '(* "http" (? "s")) str)
      nil?
      not))

(defn ssh-link?
  ```
  Is "str" passed is git ssh link?
  ```
  [str]
  (-> (peg/match '(* "git@") str)
      nil?
      not))

(defn user-repo
  ```
  Returns "user/repo"
  ```
  [str]
  (cond
    (http-link? str) (-> (string/split "/" str)
                         (array/slice 3 -1)
                         (string/join "/"))
    # TODO: support hosts other than github.
    (ssh-link? str) (->> str
                        (string/replace "git@github.com:" ""))
    :else str))


(defn repo-name
  ```
  Return repo name.
  ```
  [str]
  (->> str (string/split "/") array/pop))

(defn repo-link
  ```
  Return repo name.
  ```
  [str]
  (if (and (not (http-link? str))
           (not (ssh-link? str)))
    # TODO: support hosts other than github.
    # TODO: check if the repo-user matches the denv
    # user, and if so used git@
    (string/format "https://github.com/%s" str)
    str))

(defn current-branch
  ```
  Returns current git repo branch.
  ```
  [dir]
  (let [res (exec :branch [dir])]
    (res :out)))

(defn auto-commit
  ```
  Stage and commit all local changes with timestamps

  - TODO: check against uncommitted changes as well
  - TODO: make it optional to write commit message in editor
  ```
  [dir]
  (def- title (string "Update: " (datetime)))
  (def- desc (string/format `Powered by %s Version: %s`
                            (cfg :denv/upstream)
                            (cfg :denv/version)))
  (def- name (repo-name dir))
  (exec :stage-all [dir])
  (csh/run ["git" "-C" dir "commit" "-m" title "-m" desc])
  (printf (csucc "auto staged and committed local changes at %s successfully.")
          name))

(defn auto-push
  ```
  Push local commits to remote.
  ```
  [dir]
  (def- name (repo-name dir))
  (printf (cinfo "pushing local commits to %s remote. ") name)
  (let [res (exec :push [dir (current-branch dir)])]
    (if (res :succ)
      (printf (csucc "Pushed local commits to %s remote. ") name)
      (printf (cerr "%s local commits couldn't be pushed output: %s")
              name (res :out)))))

(defn pull
  ```
  pull remote changes, backup local changes if any to tmp.
  FIXME: if tmp branch exists, local changes will be
  committed to current branch.
  ```
  [dir]
  (when (unstaged-changes? dir)
    (def- branch (current-branch dir))
    (printf "Backing up unstated changes in %s to tmp branch ..."
            (repo-name dir))
    (var tmp "tmp")
    (exec :branch-create [dir tmp])
    (auto-commit dir)
    (exec :checkout [dir branch]))
  (exec :pull [dir (current-branch dir)]))

(defn clone
  ```
  Clone a repo into a local filesystem. Optionally with a specific branch.
  ```
  # TODO: consider cloning then checking out the branch.
  [source dir &opt branch]
  (if (string? branch)
    (exec :clone-branch [source branch dir])
    (exec :clone [source dir])))

(defn sync
  ```
  Sync current changes with remote repo.
  This should auto-commit changes if any and push to rempte.
  ```
  [dir]
  (if (unpushed-commits? dir)
    (let [name (repo-name dir)]
      (printf (cinfo "Syncing %s ...") name)
      (auto-commit dir)
      (auto-push dir)
      (printf (cinfo "Synced %s local changes with remote repo") name))
    (printf (cinfo "%s is in sync with remote repo") (repo-name dir))))

