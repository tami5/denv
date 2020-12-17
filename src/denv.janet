(import argparse :prefix "")
(import src/denv/pkg)
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

   :dep ["Profile manager Capabilities"
         "ensure" {:kind :option
                   :short "e"
                   :help "add a new dep from github user/repo"}
         "add"    {:kind :option
                   :short "a"
                   :help "add a new dep from github user/repo"}
         "remove" {:kind :option
                   :short "r"
                   :help "remove a pakcage or run dep remove function if its defined."}
         "update" {:kind :option
                   :short "u"
                   :help "update a dep by running git pull"}
         "info"   {:kind :option
                   :short "i"
                   :help "Get a table of deps installed in current environment" }
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
  (when-let [pkg (or (args "add")
                     (args "ensure"))]
    (pkg/req :add pkg))
  (when-let [pkg (args "remove")] (pkg/req :remove pkg))
  (when-let [pkg (args "update")] (pkg/req :update pkg))
  (when (args "info") (printf "Pkg info is not supported yet.")))

(defn- dep-req [& args]
  (def- args (argparse ;(params :dep))))

(defn- profile-req [& args]
  (def- args (argparse ;(params :profile))))

(defn main [& args]
  (def- feature (get args 1))
  (case feature
    "profile" (printf "Sorry %s is not yet supported." feature)
    "pkg" (pkg-req)
    "dep" (printf "Sorry %s is not yet supported." feature)
    "version" (printf "Sorry %s is not yet supported." feature)
    "update" (printf "Sorry %s is not yet supported." feature)))

