(defn cmsg [t msg]
  (let [reset "\e[39;49m"]
    (case t
      :succ (string "\e[32m" msg reset)
      :err  (string "\e[31m" msg reset)
      :info (string reset msg reset))))

(defn cinfo [msg]
  (cmsg :info msg))

(defn cerr [msg]
  (cmsg :err msg))

(defn csucc [msg]
  (cmsg :succ msg))
