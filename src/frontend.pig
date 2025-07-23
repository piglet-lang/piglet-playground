(module frontend
  (:import
    tree-widget
    [dom :from piglet:dom]))

(defn ^:async eval-print [f]
  (when f
    (.then (eval f)
      (fn [v]
        (dom:prepend (dom:query-one "#output")
          (dom:dom [:<>
                    [:p (print-str f)]
                    [:p "=> " (print-str v)]]))))))

(dom:listen!
  (dom:query-one "textarea")
  ::k
  "keypress"
  (fn ^:async [{:props [keyCode ctrlKey] :as e}]
    (if (and (= 13 keyCode) ctrlKey)
      (let [r (string-reader (.-value (.-target e)))]
        (loop [f (.read r)]
          (when f
            (eval-print f)
            (recur (.read r))))))))

(defprotocol TreeData
  (-children [this])
  (-node [this path]))

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
    {:label (fqn this)
     :leaf false
     :expanded false})

  Var
  (-node [this path]
    {:label (.repr this)
     :leaf true
     :expanded false}))



(dom:append
  (dom:el-by-id "module-browser")
  (dom:dom [tree-widget:tree
            {:children -children :node -node}
            module-registry]))
