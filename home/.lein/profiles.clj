{:user
 {:global-vars {^:dynamic *print-length* 200}
  :plugins      [[cider/cider-nrepl "0.10.0"]
                 [refactor-nrepl "2.0.0-SNAPSHOT"]]
  :dependencies [[alembic "0.3.2"]
                 [org.clojure/tools.nrepl "0.2.12"]
                 [org.clojure/tools.namespace "0.2.7"]
                 [org.clojure/tools.trace "0.7.8"]
                 [spyscope "0.1.5"]
                 [evalive "1.1.0"]
                 [envvar "1.1.0"]
                 [io.aviso/pretty "0.1.8"]
                 [im.chit/vinyasa "0.3.4"]]
  :injections
  [(require 'spyscope.core)
   (require '[vinyasa.inject :as inject])
    (require '[evalive.core])
   (inject/in ;; the default injected namespace is `.`
    ;;[vinyasa.inject :refer [inject [in inject-in]]]
    ;;[vinyasa.lein :exclude [*project*]]

    ;; imports all functions in vinyasa.pull
    [vinyasa.pull :all]

    ;; inject into clojure.core
    clojure.core
    [vinyasa.reflection .> .? .* .% .%> .& .>ns .>var]

    ;; inject into clojure.core with prefix
    clojure.core >
    [clojure.tools.trace trace-vars]
    [clojure.repl doc source]
    [clojure.pprint pprint pp]
    [clojure.java.shell sh])]}}
