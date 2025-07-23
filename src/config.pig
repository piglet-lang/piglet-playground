(module config
  "Stub configuration handling"
  (:import
    [fs :from "node:fs"]))

(def local-config (box nil))

(defn read-pig-file [f]
  (read-string (.toString (fs:readFileSync "config.local.pig"))))

(defn value [k]
  (when-not @local-config
    (reset! local-config (read-pig-file)))
  (get @local-config k))
