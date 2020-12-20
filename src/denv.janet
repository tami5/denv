(import argparse :prefix "")
(import src/denv/pkg)
(import src/denv/dep)

(def params
  {:pkg ["Package manager Capabilities"
         "ensure" {:kind :option
                   :short "e"
                   :help "ensure/install new package"}
         "add"    {:kind :option
                   :short "a"
                   :help "ensure/install new package"}
         "remove" {:kind :option
                   :short "r"
                   :help "remove/uninstall package"}
         "update" {:kind :option
                   :short "u"
                   :help "update a package"}
         "info"   {:kind :option
                   :short "i"
                   :help "Get a table of packages installed with denv." }
         :default {:kind :accumulate}]

   :dep ["Dep manager Capabilities"
         "ensure" {:kind :option
                   :short "e"
                   :help "add a new dep from github user/repo"}
         "remove" {:kind :option
                   :short "r"
                   :help "remove a pakcage or run dep remove function if its defined."}
         "update" {:kind :option
                   :short "u"
                   :help "update a dep by running git pull"}
         "sync" {:kind :option
                   :short "u"
                   :help "Sync local changes with remote by running git push."}
         "info"   {:kind :option
                   :short "i"
                   :help "Get a table of deps installed in current environment"}
         "branch" {:kind :option
                   :short "b"
                   :help "What branch to clone."}
         "local"  {:kind :flag
                   :short "l"
                   :help "Whether to clone this dep into user/deps or denv/deps."}
         :default {:kind :accumulate}]

   :profile ["Profile manager Capabilities"
             "ensure" {:kind :option
                       :short "e"
                       :help "ensure a profile"}
             "remove" {:kind :option
                       :short "r"
                       :help "remove a profile"}
             "update" {:kind :option
                       :short "u"
                       :help "update a profile pkgs and deps."}
             "info"   {:kind :option
                       :short "i"
                       :help "Get a table of profiles ensured in current environment." }
             :default {:kind :accumulate}]})

(defn- pkg-req [& args]
  (def- args (argparse ;(params :pkg)))
  (when-let [pkg (or (args "add") (args "ensure"))] (pkg/req :add pkg))
  (when-let [pkg (args "remove")] (pkg/req :remove pkg))
  (when-let [pkg (args "update")] (pkg/req :update pkg))
  (when (args "info") (printf "Pkg info is not supported yet.")))

(defn- dep-req [& args]
  (def- args (argparse ;(params :dep)))
  (def- options {:branch (args "branch") :local (args "local")} )
  (when-let [dep (args "ensure")] (dep/req :ensure (merge options {:repo dep})))
  (when-let [dep (args "sync")]   (dep/req :sync (merge options {:repo dep})))
  (when-let [dep (args "update")] (dep/req :update (merge options {:repo dep})))
  (when-let [dep (args "remove")] (dep/req :remove (merge options {:repo dep})))
  (when (args "info") (printf "Dep info is not supported yet.")))

(defn- profile-req [& args]
  (def- args (argparse ;(params :profile))))

(defn main [& args]
  (def- feature (get args 1))
  (case feature
    "profile" (printf "Sorry %s is not yet supported." feature)
    "pkg" (pkg-req)
    "dep" (dep-req)
    "version" (printf "Sorry %s is not yet supported." feature)
    "update" (printf "Sorry %s is not yet supported." feature)))

