{:user
 {:global-vars {^:dynamic *print-length* 200}
  :plugins [[cider/cider-nrepl "0.10.0-SNAPSHOT"]]
  :dependencies [[org.clojure/tools.nrepl "0.2.7"]
                 [spyscope "0.1.5"]
                 [org.clojure/tools.namespace "0.2.7"]
                 [org.clojars.gjahad/debug-repl "0.3.3"]
                 [refactor-nrepl "1.1.0"]
                 [org.clojure/tools.trace "0.7.8"]
                 [evalive "1.1.0"]
                 [envvar "1.1.0"]
                 [io.aviso/pretty "0.1.8"]
                 [im.chit/vinyasa "0.3.4"]]
  :injections
  [(require 'spyscope.core)
   (use 'spyscope.repl)
   (require '[vinyasa.inject :as inject])
   (require 'io.aviso.repl)
    (require '[evalive.core])
   (inject/in ;; the default injected namespace is `.`
    ;;[vinyasa.inject :refer [inject [in inject-in]]]
    ;;[vinyasa.lein :exclude [*project*]]

    ;; imports all functions in vinyasa.pull
    [vinyasa.pull :all]

    ;; same as [cemerick.pomegranate
    ;;           :refer [add-classpath get-classpath resources]]
    ;;[cemerick.pomegranate add-classpath get-classpath resources]


    ;; inject into clojure.core
    clojure.core
    [vinyasa.reflection .> .? .* .% .%> .& .>ns .>var]

    ;; inject into clojure.core with prefix
    clojure.core >
    [clojure.tools.trace trace-vars]
    [clojure.repl doc source]
    [clojure.pprint pprint pp]
    [alex-and-georges.debug-repl debug-repl]
    [clojure.java.shell sh])]}}
