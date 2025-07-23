(module markup
  (:import
    [sc :from contrib:styled-component]))

(sc:defc header
  {:padding "0 1rem"
   :border-bottom "1px solid var(--theme-color-gray-7)"}
  ([]
    [:header
     [:h1 "Piglet Playground"]]))

(sc:defc code-pane
  {:display "flex"
   :flex-direction "column"
   :min-height "100%"}
  [:>textarea
   {:flex-grow 1
    :background-color "inherit"
    :border "none"}]
  ([]
    [:div
     [:h2 "Code"]
     [:textarea]
     ]))

(sc:defc output-pane
  ([]
    [:div
     [:h2 "Output"]
     [:div#output]
     ]))

(sc:defc module-browser
  ([]
    [:div#module-browser
     [:h2 "Modules"]
     ]))

(sc:defc main-section
  {:display "flex"
   :flex-direction "row"
   :flex-grow 1}
  [:>* {:flex-grow 1
        :padding "1rem"
        :background-color "var(--theme-color-gray-8)"}]
  [">*:not(:last-child)"
   {:border-right "1px solid var(--theme-color-gray-7)"}]
  ([]
    [:main
     [module-browser]
     [code-pane]
     [output-pane]
     ]))

(sc:defc playground
  {:display "flex"
   :flex-direction "column"
   :flex-grow 1}
  ([]
    [:div
     [header]
     [main-section]]))
