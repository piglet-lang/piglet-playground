;; Simple code snippets to copy-paste into the playground
;;;;;;;;;;;;;;;;;;;;;;

(module user
  (:import
    [dom :from piglet:dom]
    [reactive :from piglet:reactive]))

(def n (reactive:cell 0))

(reactive:reaction!
  (dom:replace-children
    (dom:el-by-id "ui")
    (dom:dom [:h1 {:on-click #(swap! n inc)} "test: " @n])))

;;;;;;;;;;;;;;;;;;;;;;
