(import testament :prefix "" :exit true)
(import src/denv/util/fs)

# (deftest send-system-notfication
#   (is (utils/notify 
#         :title "title" 
#         :subtitle "subtitle"
#         :timeout 5000)))

(deftest fs/ensure
  (def- file "/tmp/denv_test.txt")
  (def- dir "/tmp/denv")
  (do (fs/ensure file) (fs/ensure dir))

  (assert-expr (= :file ((os/stat file) :mode)) "Creates files")
  (assert-expr (= :directory ((os/stat dir) :mode)) "Creates directories")

  (def- file-m ((os/stat file) :modified))
  (def- dir-m ((os/stat dir) :modified))
  (do (fs/ensure file) (fs/ensure dir))

  (assert-expr (= file-m ((os/stat file) :modified)) "It doesn't override/recreate files")
  (assert-expr (= dir-m ((os/stat dir) :modified)) "It doesn't override/recreate directories")

  (do (fs/rm file) (fs/rm dir)))

(deftest fs/exists? 
  (is (not (fs/exists? "/tmp/doesnt-exists"))))

(deftest fs/dir?
  (is (fs/dir? "/tmp")))

(deftest fs/visible? 
  (is (fs/visible? "/tmp"))
  (is (not (fs/visible? "/afdf")) "Should return false for invalid paths."))

(deftest fs/hidden? 
  (is (fs/hidden? (string (os/getenv "HOME") "/.config")))
  (is (not (fs/hidden? "/.tmp")) "Should return false for invalid paths."))

(deftest fs/readable? 
  (is (fs/readable? (string (os/getenv "HOME") "/.gitconfig")))
  (is (not (fs/readable? "/.tmp")) "Should return false for invalid paths.")
  (is (not (fs/readable? (string (os/getenv "HOME") "/.config"))) "It shouldn't work on directories"))

# (deftest logs-to-denv-log-file
#   ((fn [] (utils/log :test :add "test")))
#   (def expect
#     (string/format "[%s] [TEST] [ADDED] ['test']" (utils/datetime)))
#   (def test 
#     (as-> (utils/ep (string (utils/ep utils/cache) "/state.log")) ?
#           (slurp ?) 
#           (string/split "\n" ?)
#           (array/remove ? -2)
#           (array/pop ?)))
#   (is (= test expect)))

(run-tests!)
