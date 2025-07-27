(module frontend/code-area
  (:import
    [dom :from piglet:dom]))

(def dom-el (dom:query-one "textarea"))

(defn init! []
  (println "init frontend/code-area")
  (dom:listen!
    dom-el
    ::k
    "keypress"
    (fn ^:async [{:props [keyCode ctrlKey] :as e}]
      (if (and (= 13 keyCode) ctrlKey)
        ((resolve 'https://piglet-lang.org/packages/piglet-playground:frontend/editor-state:eval-buffer!))))))
