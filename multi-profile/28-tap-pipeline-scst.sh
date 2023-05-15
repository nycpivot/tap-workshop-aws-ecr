#!/bin/bash

build_cluster_name=tap-build

kubectl config use-context $build_cluster_name

rm pipeline-scst.yaml
cat <<EOF | tee pipeline-scst.yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: developer-defined-tekton-pipeline
  labels:
    apps.tanzu.vmware.com/pipeline: test      # (!) required
spec:
  params:
    - name: source-url                        # (!) required
    - name: source-revision                   # (!) required
  tasks:
    - name: test
      params:
        - name: source-url
          value: \$(params.source-url)
        - name: source-revision
          value: \$(params.source-revision)
      taskSpec:
        params:
          - name: source-url
          - name: source-revision
        steps:
          - name: test
            image: gradle
            script: |-
              cd `mktemp -d`
              wget -qO- \$(params.source-url) | tar xvz -m
              ./mvnw test
EOF

kubectl apply -f pipeline-scst.yaml