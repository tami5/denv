(import testament :prefix "" :exit true)
(import src/dotenv/utils)

(deftest send-system-notfication
  (is (utils/notify 
        :title "title" 
        :subtitle "subtitle"
        :timeout 5000)))

(deftest creates-new-file-dir
  (is (= true
         (let [file "/tmp/dotenv_test.txt"
               dir "/tmp/dotenv"]
           (utils/ep file)
           (utils/ep dir)
           (and (not (nil? (os/stat file)))
                (not (nil? (os/stat dir))))))))

(deftest logs-to-dotenv-log-file
  ((fn [] (utils/log :test :add "test")))
  (def expect
    (string/format "[%s] [TEST] [ADDED] ['test']" (utils/datetime)))
  (def test 
    (as-> (utils/ep (string (utils/ep utils/cache) "/state.log")) ?
          (slurp ?) 
          (string/split "\n" ?)
          (array/remove ? -2)
          (array/pop ?)))
  (is (= test expect)))

(run-tests!)
