(import sh)
(import path)

(defn exists?
  [path] 
  (not (nil? (os/stat path))))

(defn file? [path]
  (= :file 
     (os/stat path :mode)))

(defn dir? [path]
  (= :directory 
     (os/stat path :mode)))

(defn hidden? [path]
  # TODO: should take into account path stat
  (string/has-prefix?
   "."
   (path/basename path)))

(defn visible? [path]
  (not (hidden? path)))

(defn readable? [path] 
  (when-let [stat (os/stat path)] 
    (or (= :file (stat :mode))
        (= :link (stat :mode)))))

(defn mkdir [path]
  (sh/$ mkdir -p ,path))

(defn touch [path]
  (sh/$ touch ,path))

(defn dirs [path]
  (filter dir? (os/dir path)))

(defn ensure 
  "Given a path of a file or a dir, ensure the file 
  or directory exists and return back the path."
  [path & kind]
  (when (not (exists? path))
    (if-not (or (string? (path/ext path)) (= kind :file)) 
      (mkdir path)
      (do (when (not (exists? (path/dirname path)))
            (mkdir (path/dirname path)))
        (touch path)))) 
    path)

(defn with-open 
  "Given a mode, string and a file, 
   write the string to the file."
  [mode str file]
  (let [f (file/open file mode)] 
    (file/write f str)
    (file/close f)))

(defn rm [path]
  (if (dir? path) 
    (sh/$ rm -rf ,path)
    (sh/$ rm ,path)))

(defn cp
  [source dest cache]
  (case ((os/stat source) :mode)
    :directory (mkdir dest)
    (spit dest (slurp source))))
