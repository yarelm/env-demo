# env-demo

* Clone this repo
* Go to the `tf` directory and following the README instructions there
* Run `kustomize build argo/. | kubectl apply -f -` (This will install ArgoCD on the K8s cluster and our example personal argo applications)
  * Note: if you are using `kubectl apply -k argo` instead, it might not work as expected due to a kustomize version issue.
* Run `kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2` to get the initial ArgoCD login password
* Run `kubectl port-forward svc/argocd-server -n argocd 8080:443` to expose ArgoCD locally at port 8080
* Browse to `https://localhost:8080` and login as user: admin, and password as the one obtained through the previous step
* Profit!


Cleanup:
* Run `terraform destroy -var-file=personal.tfvars` in the `tf` directory
