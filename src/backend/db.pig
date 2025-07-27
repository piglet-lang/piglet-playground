(module backend/db
  (:import
    config
    [pg :from "pg"]))

(def client
  (pg:Client.
    #js {:host     (config:value :db/host "localhost")
         :port     (config:value :db/port 5432)
         :user     (config:value :db/user "pigplay")
         :password (config:value :db/password "pigplay")
         :database (config:value :db/database "pigplay")}))

(defn ^:async init! []
  (await (.connect client)))

(comment
  (.-rows
    (await (client.query "SELECT * FROM foo"))))
