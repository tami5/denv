(import sh)
(use src/denv/core)

```
{ 
 :method [:pull :status :clone :branch :push]
 :force false 
 :root (or "path" (os/cwd))
 :raw ["arg" "arg"]
 :source "path"
 :target "path"
}

```

(defn- valid-source? 
  "When source is non-nil and not valid, 
  print err and trigger OS level notification."
  [&opt source]
  (when (string? source) 
    (let [valid (fn [p s] (number? (string/find p s)))
          http "https" ssh "git@"
          con (not (or (valid http source) (valid ssh source)))
          msg (string/format 
                "Invalid: clone source: \"%s\"" 
                source)] 
      (when con
        (notify "GIT" msg true)
        (error msg)))))

(defn- valid-root? 
  "When root is non-nil and not valid, 
  print err and trigger OS level notification"
  [&opt root]
  (when (string? root) 
    (let [con (nil? (os/stat root))
          msg (string/format 
                "Invalid: project root: \"%s\"" 
                root)] 
      (when con
        (notify "GIT" msg true)
        (error msg)))))

(defn- valid-target? [&opt path]
  "When target is non-nil and not valid, 
  print err and trigger OS level notification."
  (when (string? path) 
    (let [con (not (nil? (os/stat path)))
          msg (string/format 
                "Invalid: clone target: \"%s\" already exists." 
                path)] 
      (when con
        (notify "GIT" msg true)
        (error msg)))))

(defn- valid? 
  "Check opts values passed. stop execution when err."
  [opts] 
  (valid-source? (opts :source))
  (valid-target? (opts :target))
  (valid-root? (opts :root)))

(defn- method 
  "Based on the opts provided, format args."
  [opts]
  (when (or (= :struct (type opts))
            (= :table (type opts))) 
    (let [m (opts :method)] 
      (case m 
        :clone @[(string m) 
                 (opts :source) 
                 (opts :target)]
        :branch @["rev-parse" "--abbrev-ref" "HEAD"]
        @[(string m)]))))

(defn- args 
  "Process opts and return the args to be ran by `run`."
  [opts]
  (let [root (when (= :string (type (opts :root))) 
               @["-C" (opts :root)])]
    (if-not (nil? root) 
      (array/concat root (method opts))
      (method opts))))

(defn- run [& args]
  (let [buf @""
        status (first (sh/run* [;args :> buf :> [stderr stdout]]))]
    {:result (if (= 0 status) :success :error)
     :output (-> buf string/slice string/trimr)}))

(defn request 
  "Run git process."
  [o]
  (let [defaults {:dry-run false}
        opts (merge defaults o)
        args (args o)]
    (valid? opts)
    (if-not (opts :dry-run) 
      (if (= :success ((run "git" ;args) :result))
        (notify "GIT" 
                (string "For some reason, the following git process has failed. args: \n" 
                        (string/join args " ")) 
                true)) 
      (array/insert args 0 "git"))))

(defn clone 
  "example: (clone \"source\" \"target\" {:dry-run false}) "
  [source target &opt opts]
  (let [opts (merge {:method :clone 
                     :source source
                     :target target} opts)]
   (request opts)))
