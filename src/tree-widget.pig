(module tree-widget
  (:import
    [dom :from piglet:dom]
    [sc :from contrib:styled-component]))

(def styles
  [[".tree-item[aria-expanded=true]>.expand" {:display "none"}]
   [".tree-item[aria-expanded=false]>.collapse" {:display "none"}]
   ])

(declare subtree)

(sc:defc tree-item
  ([{:keys [children node on-click on-expand on-collapse] :as cfg} path data]
    (let [{:keys [leaf expanded label]} (node data path)
          on-click-handler (fn [_] (on-click data path))]
      (if leaf
        [:li {:role "treeitem"
              :on-click on-click-handler} label]
        [:li {:role "treeitem" :aria-expanded expanded}
         [:button.expand
          {:on-click (fn [{:props [target]}]
                       (dom:set-attr (dom:parent target) :aria-expanded true))}
          "+"]
         [:button.collapse
          {:on-click (fn [{:props [target]}]
                       (dom:set-attr (dom:parent target) :aria-expanded false))}
          "-"]
         [:span {:on-click on-click-handler}
          label]
         [subtree cfg (conj path data) data]]))))

(sc:defc subtree
  ([{:keys [children node] :as cfg} path data]
    [:ul {:role "group"}
     (for [ch (children data)]
       [tree-item cfg (conj path data) ch])]))

(sc:defc tree
  ["[role=\"treeitem\"][aria-expanded=\"false\"] > [role=\"group\"]"
   {:display "none"}]
  ([{:keys [children node] :as cfg} data]
    [:ul {:role "tree"}
     (for [ch (children data)]
       [tree-item cfg [data] ch])]))
