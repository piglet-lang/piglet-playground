(module frontend/package-tree
  (:import
    tree-widget
    [dom :from piglet:dom]
    frontend/code-area
    frontend/editor-state))

(defonce tree-component (box nil))

(defprotocol TreeData
  (-children [this])
  (-node [this path])
  (-on-click [this path]))

(def ModuleRegistry (.-constructor module-registry))

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
    {:label (.-name this)
     :leaf false
     :expanded false})
  (-on-click [this path]
    (frontend/editor-state:switch-to-module! this))

  Var
  (-node [this path]
    {:label (str (.repr this) #_" (" #_(:line (meta xxx)) #_")")
     :leaf true
     :expanded false})
  (-on-click [this path]))

(defn render-package-tree! []
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
                         (render-package-tree!))
       :on_new_module (fn [p m]
                        (conj! (.-listeners m) module-listener)
                        (render-package-tree!))
       :on_new_var (fn [p m v]
                     (render-package-tree!))})

(defn init! []
  (println "init frontend/package-tree")
  (render-package-tree!)

  (doseq [p (js:Object.values (.-packages module-registry))]
                           (conj! (.-listeners p) module-listener)
                           (doseq [v (js:Object.values (.-modules p))]
      (conj! (.-listeners p) module-listener)))

  (conj! (.-listeners module-registry) module-listener))
