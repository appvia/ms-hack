create-id() {

    local IDENTITY_NAME=${1:?"missing IDENTITY NAME"}
    local IDENTITY_RESOURCE_GROUP=${2:?"missing IDENTITY RESOURCE GROUP"}

    az identity create -g ${IDENTITY_RESOURCE_GROUP} -n ${IDENTITY_NAME}
}

apply-id() {
    local IDENTITY_NAME=${1:?"missing IDENTITY NAME"}
    local IDENTITY_RESOURCE_GROUP=${2:?"missing IDENTITY RESOURCE GROUP"}

    IDENTITY_CLIENT_ID="$(az identity show -g ${IDENTITY_RESOURCE_GROUP} -n ${IDENTITY_NAME} --query clientId -otsv)"
    IDENTITY_RESOURCE_ID="$(az identity show -g ${IDENTITY_RESOURCE_GROUP} -n ${IDENTITY_NAME} --query id -otsv)"

    cat <<EOF | kubectl apply -f -
apiVersion: "aadpodidentity.k8s.io/v1"
kind: AzureIdentity
metadata:
  name: ${IDENTITY_NAME}
spec:
  type: 0
  resourceID: ${IDENTITY_RESOURCE_ID}
  clientID: ${IDENTITY_CLIENT_ID}
EOF


cat <<EOF | kubectl apply -f -
apiVersion: "aadpodidentity.k8s.io/v1"
kind: AzureIdentityBinding
metadata:
  name: ${IDENTITY_NAME}-binding
spec:
  azureIdentity: ${IDENTITY_NAME}
  selector: horris
EOF

}

$@