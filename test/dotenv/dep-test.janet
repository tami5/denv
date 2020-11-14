(import testament :prefix "" :exit true)
(import src/dotenv/dep)
(import src/dotenv/utils)

(deftest clones-to-config-path 
  (is (= (dep/ensure "tami5/nvim") # returns the path where it got downloaded
         )
    )

  )

(run-tests!)
