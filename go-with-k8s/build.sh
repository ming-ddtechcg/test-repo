#!/bin/sh

docker build -t harbor.ddtechcg.com:5001/playground/myapp:test . 

docker push harbor.ddtechcg.com:5001/playground/myapp:test

