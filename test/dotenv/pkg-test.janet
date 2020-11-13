(import testament :prefix "" :exit true)
(import src/dotenv/pkg :as pkg)
(import src/dotenv/utils)

(when (= :linux (os/which))
  (deftest pkg-command-is-formated-correctly?
    (is (=["/usr/bin/pacman" "--noconfirm" "-Q" "github-cli"] 
                             (pkg/cmd :check "github-cli")))

    (is (= ["/usr/bin/pacman" "--noconfirm" "-S" "github-cli"] 
           (pkg/cmd :add "github-cli")))

    (is (= ["/usr/bin/pacman" "--noconfirm" "-R" "github-cli"] 
           (pkg/cmd :remove "github-cli")))
    (is (= ["/usr/bin/pacman" "--noconfirm" "-S" "github-cli"] 
           (pkg/cmd :upgrade "github-cli")))))

(deftest changes-on-pkgs-gets-logged?
  (defn- content [file] 
    (as-> (utils/ep (string (utils/ep utils/cache) "/" file)) ?
          (slurp ?) 
          (string/split "\n" ?)
          (array/remove ? -2)
          (array/pop ?)))
  (def- random-str (string (math/random) "-test-pkg" ))
  (is (= (do (pkg/log! :add random-str) random-str)
         (content "new-pkgs.txt")))
  (is (= (do (pkg/log! :remove random-str) random-str)
         (content "removed-pkgs.txt")))
  (is (= (do (pkg/log! :upgrade random-str) random-str) 
         (content "upgraded-pkgs.txt"))))

(run-tests!)
