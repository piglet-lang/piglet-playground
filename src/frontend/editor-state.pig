(module frontend/editor-state
  (:import
    piglet:dom
    frontend/code-area
    piglet:reactive))

(def this-package (qsym (str js:window.location)))

(def state
  (reactive:cell
    (let [user-mod (qsym (str this-package ":user"))]
      {:modules {}
       :current-module user-mod})))

(def modules (reactive:cursor state [:modules]))
(def current-module (reactive:cursor state [:current-module]))
(def code-contents (reactive:formula (get @modules @current-module)))
(def current-package (reactive:formula
                       (.find_package module-registry (.-pkg @current-module))))

(defn ^:async fetch-module-text [module]
  (await (.text (await (js:fetch (.-location module))))))

(defn switch-to-module! [mod]
  (let [mod-name (.-fqn mod)]
    (when-not (has-key? @modules mod-name)
      (.then (fetch-module-text mod) (fn [txt]
                                       (swap! modules assoc mod-name txt))))
    (reset! current-module (.-fqn mod))))

(defn insert-result [form value]
  (dom:prepend (dom:query-one "#output")
    (dom:dom [:<>
              [:pre [:code (print-str form)]]
              [:pre [:code "=> " (print-str value)]]])))

(defn handle-module-rename [new-mod-name]
  (let [pkg @current-package]
    ;; A tad hacky, since we don't normally remove modules
    (dissoc! (.-modules pkg) (munge (.-mod @current-module)))
    (let [new-mod (.ensure_module pkg new-mod-name)]
      (swap! state (fn [s]
                     (-> s
                       (update :modules dissoc (:current-module s))
                       (assoc-in [:modules (.-fqn new-mod)] (get-in s [:modules (:current-module s)]))
                       (assoc :current-module (.-fqn new-mod))))))))

(defn ^:async eval-print [f]
  (when f
    (when (and
            (list? f)
            (= 'module (first f))
            (not= (.-mod @current-module) (second f)))
      (handle-module-rename (str (second f))))
    (.then (eval f) (partial insert-result f))))

(defn eval-string [s]
  (let [r (string-reader s)]
    (loop [f (.read r)]
      (when f
        (eval-print f)
        (recur (.read r))))))

(defn eval-buffer! []
  (let [mod (find-module @current-module)
        pkg (.find_package module-registry (.-pkg mod))]
    (binding [*current-package* pkg
              *current-module* mod]
      (eval-string @code-contents))))

(defn init! []
  (println "init frontend/editor-state")

  (.ensure_module
    (.ensure_package module-registry (.-pkg @current-module))
    (.-mod @current-module))

  (dom:listen!
    frontend/code-area:dom-el
    :code-area-state
    "input"
    (fn [e]
      (swap! modules assoc @current-module (.-value (.-target e)))))

  (reactive:reaction!
    (let [contents @code-contents]
      (when-not (= contents (.-value frontend/code-area:dom-el))
        (set! (.-value frontend/code-area:dom-el) contents))))

  (reactive:reaction!
    (set! (.-innerHTML (dom:query-one ".code-pane h2"))
      (.-outerHTML
        (dom:dom [:span {:title (fqn @current-module)}
                  "Module: " (.-mod @current-module)]))))

  (swap! state assoc-in [:modules @current-module] "(module user)"))
