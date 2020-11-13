(import testament :prefix "" :exit true)
(import src/dotenv/pkg :as pkg)

(when (= :linux (os/which))

  # Command format
  (deftest is-check-cmd-correct
    (def expected ["/usr/bin/pacman" "--noconfirm" "-Q" "github-cli"])
    (is (= expected
           (pkg/cmd :check "github-cli"))))

  (deftest is-install-cmd-correct 
    (def expected ["/usr/bin/pacman" "--noconfirm" "-S" "github-cli"])
    (is (= expected
           (pkg/cmd :add "github-cli"))))

  (deftest is-remove-cmd-correct 
    (def expected ["/usr/bin/pacman" "--noconfirm" "-R" "github-cli"])
    (is (= expected
           (pkg/cmd :remove "github-cli"))))

  (deftest is-upgrade-cmd-correct 
    (def expected ["/usr/bin/pacman" "--noconfirm" "-S" "github-cli"])
    (is (= expected
           (pkg/cmd :upgrade "github-cli"))))
  )


  (run-tests!)
