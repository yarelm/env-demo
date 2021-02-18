# ArgoCD installation and application creation
* `/install` contains manifests which will install ArgoCD in the `argocd` namespace
* `/apps` contains manifest which will install ArgoCD's configuration as ArgoCD application ([bootstrap as shown here](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#manage-argo-cd-using-argo-cd)), and also install per-environment applications.


## Steps
* Make sure your kubectl context is set to the GKE cluster created in the previous part (the Terraform part) - This can be done with running:
  `gcloud container clusters get-credentials host-cluster --region us-west1 --project HOST_PROJECT_ID` where HOST_PROJECT_ID appears after the `terraform apply` step.
* Run `kustomize build install/ | kubectl apply -f -` (This will install ArgoCD on the K8s cluster )
  * Note: you need to install kustomize for this to work. if you are using `kubectl apply -k argo` instead, it might not work as expected due to a kustomize version issue.
* Wait until all of ArgoCD pods are up and ready...
* Run `kubectl apply -f apps` (This will install our example personal argo applications)
* Run `kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2` to get the initial ArgoCD login password
* Run `kubectl port-forward svc/argocd-server -n argocd 8080:443` to expose ArgoCD locally at port 8080
* Browse to `https://localhost:8080` and login as user: admin, and password as the one obtained through the previous step
* You will notice 3 ArgoCD applications are shown: argocd-config, moses-env, david-env
