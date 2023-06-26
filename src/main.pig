(module main
  (:import
    [_ :from piglet:pdp-client]
    [dom :from piglet:dom]))

(println "Hello from piglet!")

(def app (dom:find-by-id js:document "app"))
(def code (dom:find-by-id js:document "code"))
(def preview-frame (dom:find-by-id js:document "preview-frame"))
(def console (dom:find-by-id js:document "console"))

(def run-btn (dom:find-by-id js:document "run"))

(def pdoc (.-contentDocument preview-frame))
(def pwindow (.-contentWindow preview-frame))
(println pdoc)

;; (set! (-> pdoc .-body .-style .-backgroundColor) "cyan")

(def papp (dom:find-by-id pdoc "app"))

(defn piglet-eval-in-preview [code]
  ((-> pwindow .-$piglet_compiler$ .-eval_string) code))

(.addEventListener run-btn "click" (fn [e]
                                     
                                     (.then (piglet-eval-in-preview (.-value code))
                                       (fn [val]
                                         (println "hello frmo val: " val)
                                         (set! (.-innerText console) (str "piglet=> " val))))))
