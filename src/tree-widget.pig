(module tree-widget
  (:import
    [dom :from piglet:dom]
    [sc :from contrib:styled-component]))

(def styles
  [["[role=\"treeitem\"][aria-expanded=\"false\"] > [role=\"group\"]"
    {:display "none"}]])

(declare subtree)

(sc:defc tree-item
  ([{:keys [children node] :as cfg} path data]
    (let [{:keys [leaf expanded label]} (node data path)]
      (if leaf
        [:li {:role "treeitem"} label]
        [:li {:role "treeitem" :aria-expanded expanded}
         [:span {:on-click (fn [{:props [target]}]
                             (def target target)
                             (dom:set-attr (dom:parent target)
                               :aria-expanded
                               (not= "true" (dom:attr (dom:parent target) :aria-expanded))))}
          label]
         [subtree cfg (conj path data) data]]))))

(sc:defc subtree
  ([{:keys [children node] :as cfg} path data]
    [:ul {:role "group"}
     (for [ch (children data)]
       [tree-item cfg (conj path data) ch])]))

(sc:defc tree
  ([{:keys [children node] :as cfg} data]
    [:ul {:role "tree"}
     (for [ch (children data)]
       [tree-item cfg [data] ch])]))
