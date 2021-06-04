#!/usr/bin/env sh
alias oc='oc45 --server="https://api.ocparo.az.lhtcloud.com:6443" --kubeconfig="/Users/siw36/.kube/config_aro" -n rkl'
oc create imagestream nginx-hello-world
oc apply -f buildConfig.yaml
oc start-build nginx-hello-world --from-dir=./ --follow
oc run \
  --requests="cpu=200m,memory=128Mi" \
  --limits="cpu=200m,memory=128Mi" \
  --restart="Never" \
  --image-pull-policy="Always" \
  --image=$(oc get is nginx-hello-world -o=go-template='{{ .status.dockerImageRepository}}') \
  nginx-hello-world
while [[ $(oc get pods nginx-hello-world -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do
  echo "Waiting for pod..." && sleep 1;
done
oc exec nginx-hello-world -- curl localhost:8080
if [ $? -eq 0 ]; then
  echo "End to end build test successful!"
else
  echo "End to end build test failed!"
fi
oc delete pod nginx-hello-world
