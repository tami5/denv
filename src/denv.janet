(import argparse :prefix "")
(import src/denv/pkg)

(def pkg-params 
  ["Package manager Capaiblities"
   "ensure" {:kind :option 
             :short "e"
             :help "ensure/install new package"}
   "remove" {:kind :option 
             :short "r"
             :help "remove/uninstall package"}
   "update" {:kind :option 
             :short "u"
             :help "update a package"}
   "info" {:kind :option 
           :short "i"
           :help "Get a table of packages installed with denv." }
   :default {:kind :accumulate}])

(defn- pkg-req [& args]
  (let [args (argparse ;pkg-params)]
    (when-let [pkg (args "ensure")] (pkg/ensure pkg))
    (when-let [pkg (args "remove")] (pkg/remove pkg))
    (when-let [pkg (args "update")] (pkg/upgrade pkg)) # TODO if no pkg provided, 
    (when (args "info") (printf "Pkg info is not supported yet."))))

(def dep-params 
  ["Profile manager Capaiblities"
   "add" {:kind :option 
          :short "a"
          :help "add a new dep from github user/repo"}
   "remove" {:kind :option 
             :short "r"
             :help "remove a pakcage or run dep remove function if its defined."}
   "update" {:kind :option 
             :short "u"
             :help "update a dep by running git pull"}
   "info" {:kind :option 
           :short "i"
           :help "Get a table of deps installed in current enviroment" }
   :default {:kind :accumulate}])

(defn- dep-req [& args]
  (let [args (argparse ;dep-params)]))

(def profile-params 
  ["Profile manager Capaiblities"
   "ensure" {:kind :option 
             :short "e"
             :help "ensure a profile"}
   "remove" {:kind :option 
             :short "r"
             :help "remove a profile"}
   "update" {:kind :option 
             :short "u"
             :help "update a profile pkgs and deps."}
   "info" {:kind :option 
           :short "i"
           :help "Get a table of profile ensured in current enviroment." }
    :default {:kind :accumulate}])

(defn- profile-req [& args]
  (let [args (argparse ;profile-params)])) 


(defn main [& args]
  (let [feature (get args 1)
        args (array/slice args 2 -1)]
    (case feature 
       "profile" (printf "Sorry %s is not yet supported." feature)
       "pkg" (pkg-req)
       "dep" (printf "Sorry %s is not yet supported." feature)
       "version" (printf "Sorry %s is not yet supported." feature)
       "update" (printf "Sorry %s is not yet supported." feature))))
