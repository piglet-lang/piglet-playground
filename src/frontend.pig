(module frontend
  (:import
    tree-widget
    [dom :from piglet:dom]))

(def code-area (dom:query-one "textarea"))

(defn ^:async eval-print [f]
  (when f
    (.then (eval f)
      (fn [v]
        (dom:prepend (dom:query-one "#output")
          (dom:dom [:<>
                    [:pre [:code (print-str f)]]
                    [:pre [:code "=> " (print-str v)]]]))))))

(defn eval-string [s]
  (let [r (string-reader s)]
    (loop [f (.read r)]
      (when f
        (eval-print f)
        (recur (.read r))))))

(dom:listen!
  code-area
  ::k
  "keypress"
  (fn ^:async [{:props [keyCode ctrlKey] :as e}]
    (if (and (= 13 keyCode) ctrlKey)
      (eval-string (.-value (.-target e))))))

(defprotocol TreeData
  (-children [this])
  (-node [this path])
  (-on-click [this path]))

(def ModuleRegistry (.-constructor module-registry))

(defn ^:async fetch-module-text [module]
  (await (.text (await (js:fetch (.-location module))))))

(defn set-code-contents [txt]
  (set! (.-value code-area) txt))

(extend-protocol TreeData
  ModuleRegistry
  (-children [reg]
    (js:Object.values (.-packages reg)))
  (-node [this path])

  Package
  (-children [this]
    (js:Object.values (.-modules this)))
  (-node [this path]
    {:label (fqn this)
     :leaf false
     :expanded false})

  Module
  (-children [this]
    (js:Object.values (.-vars this)))
  (-node [this path]
    {:label (fqn this)
     :leaf false
     :expanded false})
  (-on-click [this path]
    (.then (fetch-module-text this) set-code-contents))

  Var
  (-node [this path]
    {:label (str (.repr this) #_" (" #_(:line (meta xxx)) #_")")
     :leaf true
     :expanded false})
  (-on-click [this path]))

(defonce tree-component (box nil))

(defn render-module-tree! []
  (swap! tree-component
    (fn [c]
      (let [t (dom:dom [tree-widget:tree
                        {:children -children
                         :node -node
                         :on-click -on-click}
                        module-registry])]
        (if c
          (dom:replace c t)
          (do
            (dom:append (dom:el-by-id "module-browser") t)
            t))))))

(def module-listener
  #js {:on_new_package (fn [p]
                         (conj! (.-listeners p) module-listener)
                         (render-module-tree!))
       :on_new_module (fn [p m]
                        (conj! (.-listeners m) module-listener)
                        (render-module-tree!))
       :on_new_var (fn [p m v]
                     (render-module-tree!))})

(conj! (.-listeners module-registry) module-listener)

(doseq [p (js:Object.values (.-packages module-registry))]
  (conj! (.-listeners p) module-listener)
  (doseq [v (js:Object.values (.-modules p))]
    (conj! (.-listeners p) module-listener)))

(render-module-tree!)
