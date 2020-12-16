# (import src/denv/pkg :as pkg)
(import argparse :prefix "")
(use src/denv/core)

# (def args (dyn :args))

# (def usage
#   "Usage"
# ``` [action]

#   Actions:
#     help               - Print this usage information
#     profile <name>     - Setup a profile
#     push               - Push changes to remote repo
#     pull               - Pull changes from remote repo
#     clean <name>       - Remove profile or all profiles
#     pkg-add <pkg>      - Add new pkg
#     pkg-rm <pkg>       - Remove a pkg
#     pkg-up <pkg>       - update a pkg
#     version            - Print the current version
# ```)

# (def action (get args 1))
# (def options (drop 2 args))

# (case action
#   "profile" (denv/ensure ;options)
#   "push"    (denv/push)
#   "pull"    (denv/pull)
#   "clean"   (denv/clean ;options)
#   "pull"    (denv/pull)
#   "pkg-add" (pkg/add ;options)
#   "pkg-rm"  (pkg/remove ;options)
#   "pkg-up"  (pkg/update ;options)
#   "version" (print denv/version)
#   (print "denv" usage))

(def params 
  [(msgs :denv/help-intro)
   "profile" {:kind :option 
              :short "pr"
              :help "Ensure a profile" }
   "config" {:kind :option 
             :short "c"
             :help "denv config to use" }
   "eliminate" {:kind :option 
                :short "e"
                :help "Eliminate a profile"}])


(defn main [&]
  (let [args (argparse ;params)]
    (pp args))
  )
