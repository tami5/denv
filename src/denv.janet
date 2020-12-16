(import src/denv/pkg)
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
  ["A simple configuration utility for managing complex setups."
   "profile-ensure" {:kind :option 
                     :short "e"
                     :help "Ensure a profile" }
   "profile-rm" {:kind :option 
                 :short "x"
                 :help "Eliminate a profile"}
   "pack-add" {:kind :option 
               :short "a"
               :help "add/install new package"}
   "pack-rm" {:kind :option 
              :short "r"
              :help "remove/uninstall package"}
   "pack-update" {:kind :option 
                  :short "u"
                  :help "update a package"}
   "config" {:kind :option 
             :short "c"
             :help "denv config to use" }
   ])


(defn main [& args]
  (with-dyns [:args args]
    (let [res (argparse (splice params))]
      (unless res
        (os/exit 1))
      (pkg/add (res "pack-add"))))
  )

# (let [args (argparse ;params)]
    
#     # (cond 
#     #  (not (empty? (args "pack-add"))) (pkg/ensure (args "pack-add")) 
#     #  (not (empty? (args "pack-rm"))) (pp (args "pack-rm")) 
#     #  (not (empty? (args "pack-upgrade"))) (pkg/upgrade (args "pack-upgrade")) 
#     #  )
#     )
