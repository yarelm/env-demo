# ArgoCD installation and application creation

* Run `kustomize build . | kubectl apply -f -` (This will install ArgoCD on the K8s cluster and our example personal argo applications)
  * Note: you need to install kustomize for this to work. if you are using `kubectl apply -k argo` instead, it might not work as expected due to a kustomize version issue.
* Run `kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2` to get the initial ArgoCD login password
* Run `kubectl port-forward svc/argocd-server -n argocd 8080:443` to expose ArgoCD locally at port 8080
* Browse to `https://localhost:8080` and login as user: admin, and password as the one obtained through the previous step
* You will notice 3 ArgoCD applications are shown: argocd-config, moses-env, david-env
