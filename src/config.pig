(module config
  "Stub configuration handling"
  (:import
    [fs :from "node:fs"]))

(def config (box nil))

(defn read-pig-file [f]
  (when (fs:existsSync f)
    (read-string (.toString (fs:readFileSync f)))))

(defn value
  ([k]
    (when-not @config
      (reset! config (merge
                       (read-pig-file "config.pig")
                       (read-pig-file "config.local.pig"))))
    (get @config k))
  ([k fallback]
    (let [v (value k)]
      (if (some? v) v fallback))))
