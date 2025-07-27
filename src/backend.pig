(module backend
  (:import
    config markup tree-widget
    contrib:html
    contrib:http/oauth
    contrib:http/router
    contrib:http/session
    [uuid :from "uuid"]
    [dev-server :from piglet:node/dev-server]
    [assets :from contrib:node/http/assets]
    [cli :from piglet:cli/parseargs]
    [css :from piglet:css]
    [fs :from "node:fs"]
    [http-server :from piglet:node/http-server]
    [path :from "node:path"]
    [str :from piglet:string]
    [sc :from contrib:styled-component]))

(defn gray [pct]
  (str "hsl(217 5% " pct "%)"))

(def styles
  (into
    [[":where(*)"
      {:box-sizing "border-box"
       :--theme-font-family "'Libre Franklin', sans-serif"
       :--theme-font-family-mono "'Iosevka Web', monospace"
       :--theme-color-gray-1 (gray 2)
       :--theme-color-gray-2 (gray 14)
       :--theme-color-gray-3 (gray 25)
       :--theme-color-gray-4 (gray 37)
       :--theme-color-gray-5 (gray 48)
       :--theme-color-gray-6 (gray 60)
       :--theme-color-gray-7 (gray 71)
       :--theme-color-gray-8 (gray 94)
       :--theme-color-gray-9 (gray 98)}]
     [:at-media {:prefers-color-scheme "dark"}
      [":where(*)"
       {:--theme-color-gray-1 (gray 98)
        :--theme-color-gray-2 (gray 83)
        :--theme-color-gray-3 (gray 71)
        :--theme-color-gray-4 (gray 60)
        :--theme-color-gray-5 (gray 48)
        :--theme-color-gray-6 (gray 37)
        :--theme-color-gray-7 (gray 25)
        :--theme-color-gray-8 (gray 14)
        :--theme-color-gray-9 (gray 2)}]]
     [#{:html :body} {:display "flex" :flex-direction "column" :height "100%"}]
     [#{:textarea :pre :code} {:font-family "var(--theme-font-family-mono)"}]
     [:html
      {:font-family "var(--theme-font-family)"
       :color "var(--theme-color-gray-1)"
       :background-color "var(--theme-color-gray-9)"}]
     [#{:html :body} {:margin 0 :padding 0}]]
    tree-widget:styles))

(defn base-layout [h]
  [:<> h])

(defn GET-index [req]
  {:status 302
   :headers {"Location" (str "/w/" (uuid:v7))}})

(defn GET-workspace [req]
  {:status 200
   :html-head [:<>
               [:meta {:charset "utf-8"}]
               [:meta {:content "width=device-width, initial-scale=1" :name "viewport"}]
               [:link {:rel "stylesheet" :href "/fonts/libre_franklin.css"}]
               [:link {:rel "stylesheet" :href "/fonts/iosevka.css"}]
               [:script {:type "importmap"} "{\"imports\":{\"astring\":\"/npm/astring\",\"mime-db\":\"/npm/mime-db\",\"redis\":\"/npm/redis\"}}"]
               [:script {:type "application/javascript" :src "/npm/source-map/dist/source-map.js"}]
               [:script {:type "module" :src "/piglet/lib/piglet/browser/main.mjs?verbosity=0"}]
               [:script {:type "piglet"}
                (str
                  '(await (load-package "/self"))
                  '(await (import 'https://piglet-lang.org/packages/piglet:pdp-client))
                  '(piglet:pdp-client:connect! "ws://127.0.0.1:17017")
                  '(await (import 'https://piglet-lang.org/packages/piglet-playground:frontend))
                  )]]
   :html
   [markup:playground]})

(defn GET-styles [req]
  {:status 200
   :headers {"Content-Type" "text/css"}
   :body (css:css (apply conj styles (sc:all-styles)))})

(defn GET-inspect [req]
  {:status 200
   :headers {"Content-Type" "text/plain"}
   :session {:foo (inc (get-in req [:session :foo] 0))}
   :body
   (str (str:upcase (name (:method req))) " "(:path req) "\n\n"
     (apply str
       (for [[k v] (:headers req)]
         (str k ": " (print-str v) "\n")))
     "\n"
     (apply str
       (for [[k v] (dissoc req :method :path :headers)]
         (str (print-str k) " " (print-str v) "\n"))))})

(defn routes []
  [["" {:html-head [:<>
                    [:link {:rel "stylesheet" :href "/fonts/libre_franklin.css"}]
                    [:link {:rel "stylesheet" :href "/styles.css"}]]
        :layout base-layout}
    ["/" {:get #'GET-index}]
    ["/w/:uuid" {:get #'GET-workspace}]
    ["/inspect" {:get #'GET-inspect}]
    ["/styles.css" {:get #'GET-styles}]]])

(defonce server (box nil))

(defn some-handler [& handlers]
  (fn ^:async [req]
    (reduce (fn ^:async [last-res h]
              (println h)
              (let [res (await (h req))]
                (if (not (or (nil? res) (= 404 (:status res))))
                  (reduced res)
                  (or res last-res))))
      nil handlers)))

(defn start-server! [opts]
  (when-let [s @server]
    (http-server:stop! s))
  (let [s (http-server:create-server
            (some-handler
              (assets:wrap-assets
                (fn [req]
                  ((http/router:router
                     (routes (:dir opts) (:origin opts))
                     {:middleware [html:wrap-render
                                   http/session:wrap-session]})
                    req))
                {:roots ["public"]})
              dev-server:handler)
            opts)]
    (reset! server s)
    (http-server:start! s)
    s))

(defn ^:async cmd-start! [{:keys [port] :as opts}]
  (println "Starting on port" port )
  (await (dev-server:register-package (str dev-server:piglet-lang-path "/packages/piglet") "piglet-lang"))
  (await (dev-server:register-package "." "self"))
  (start-server! opts))

(defn -main [& argv]
  (cli:dispatch
    {:name "Piglet-playground"
     :doc ""
     :flags ["-p, --port <port>" {:doc "Port to run on"}]
     :commands {"start" #'cmd-start!}}
    argv))

(comment
  (cmd-start! {:port 4501})
  )
