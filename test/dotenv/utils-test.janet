(import tester :prefix "" :exit true)
(import src/dotenv/utils)

(deftest 
  (test "sends system notification"
        (is (utils/notify 
              :title "title" 
              :subtitle "subtitle" # FIXME: for some reason subtitle is not showing.
              :timeout 5000))))
