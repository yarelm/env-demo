# env-demo

* Clone this repo
* Provide the required inputs by running the following commands (replace values):
   * `export TF_VAR_billing_account=YOUR_BILLING_ACCOUNT_ID`
   * `export TF_VAR_folder_id=GCP_FOLDER_ID_TO_CREATE_PROJECTS`
   * `export TF_VAR_organization_id=GCP_ORGANIZATION_ID`
* Run `terraform init`
* Run `terraform apply -var-file=personal.tfvars`
* Go over and approve the pending changes
* Wait until it's over... (it can take a while.. If you encounter an error - in some rare cases it might be beneficial to re-run the apply procedure) :smiley:
* Run `kustomize build argo/. | kubectl apply -f -` (This will install ArgoCD on the K8s cluster and our example personal argo applications)
  * Note: if you are using `kubectl apply -k argo` instead, it might not work as expected due to a kustomize version issue.
* Run `kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2` to get the initial ArgoCD login password
* Run `kubectl port-forward svc/argocd-server -n argocd 8080:443` to expose ArgoCD locally at port 8080
* Browse to `https://localhost:8080` and login as user: admin, and password as the one obtained through the previous step
