az acr login -n azgwpoccr40b01000dev01
docker tag local/nina-poc azgwpoccr40b01000dev01.azurecr.io/nina-poc 
docker push azgwpoccr40b01000dev01.azurecr.io/nina-poc

######## Pod YAML #########
---
apiVersion: v1
kind: Pod
metadata:
  name: nina
spec:
  containers:
    - image: azgwpoccr40b01000dev01.azurecr.io/nina-poc
      name: nina
