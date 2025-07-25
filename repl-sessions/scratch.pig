
(module scratch
  (:import [str :from piglet:string]))

(spit "/tmp/download_iosevka.sh"
  (str:join "\n"
  (map #(str "wget https://iosevka-webfonts.github.io/iosevka/" %)
    (map second (re-seq #"url\('([^)]+)'\)"
                  (await (slurp "/home/arne/Piglet/piglet-playground/public/fonts/iosevka.css")))))))
