---
layout: post
title: aws-lambda-clojure
---

```clojure
(ns lost-pet-lambda.core
  (:require [clojure.java.io :as io]
            [cheshire.core :as cheshire]
            [taoensso.timbre :as timbre])
  (:import (java.io InputStream OutputStream)
           (com.amazonaws.services.lambda.runtime Context))
  (:gen-class
    :methods [^:static [handler [java.io.InputStream java.io.OutputStream com.amazonaws.services.lambda.runtime.Context] void]]))

(defn -handler
  [^InputStream input-stream ^OutputStream output-stream ^Context context]
  (with-open [output output-stream
              input  input-stream
              writer (io/writer output)
              reader (io/reader input)]
    (let [request (cheshire/parse-stream reader true)]
      (timbre/info request))))
```

