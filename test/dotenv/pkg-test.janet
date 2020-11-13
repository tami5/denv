(import tester :prefix "" :exit true)
(import src/dotenv/pkg :as pkg)

(if (= :linux (os/which))
  # Command format
  (deftest
    (test "check command is formated correctly?"
          (is (= ["/usr/bin/pacman" "--noconfirm" "-Q" "github-cli"]
                 (pkg/cmd :check "github-cli"))))

    (test "install command is formated correctly?"
          (is (= ["/usr/bin/pacman" "--noconfirm" "-S" "github-cli"]
                 (pkg/cmd :add "github-cli"))))

    (test "remove command is formated correctly?"
          (is (= ["/usr/bin/pacman" "--noconfirm" "-R" "github-cli"]
                 (pkg/cmd :remove "github-cli"))))

    (test "upgrade command is formated correctly?"
          (is (= ["/usr/bin/pacman" "--noconfirm" "-S" "github-cli"]
                 (pkg/cmd :upgrade "github-cli"))))
    ))
