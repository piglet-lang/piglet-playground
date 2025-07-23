(module frontend
  (:import
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
