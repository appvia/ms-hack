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

deploy() {
    local TEST_ZONE_RESOURCE_GROUP=${1:?"missing RESOURCE GROUP for DNS ZONE"}
    local TEST_ZONE_DNS=${2:?"missing RESOURCE GROUP for DNS ZONE"}
    local IDENTITY_RESOURCE_GROUP=${3:?"missing IDENTITY RESOURCE GROUP"}
    local IDENTITY_ID_1_NAME=${4:?"missing IDENTITY 1 NAME"}
    local IDENTITY_ID_2_NAME=${5:?"missing IDENTITY 2 NAME"}
    local TEST_SUBSCRIPTION_1=${6:?"missing test subscription 1"}
    local TEST_SUBSCRIPTION_1=${7:?"missing test subscription 2"}

    IDENTITY_1_CLIENT_ID="$(az identity show -g ${IDENTITY_RESOURCE_GROUP} -n ${IDENTITY_1_NAME} --query clientId -otsv)"
    IDENTITY_2_CLIENT_ID="$(az identity show -g ${IDENTITY_RESOURCE_GROUP} -n ${IDENTITY_2_NAME} --query clientId -otsv)"

  cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    aadpodidbinding: horris
  name: ms-hack
spec:
  replicas: 1
  selector:
    matchLabels:
      aadpodidbinding: horris
  template:
    metadata:
      labels:
        aadpodidbinding: horris
    spec:
      containers:
      - image: ${REPO}/${IMAGE}:${VERSION}
        name: identify
        env:
        - name: TEST_ZONE_RESOURCE_GROUP
          value: "${TEST_ZONE_RESOURCE_GROUP}"
        - name: TEST_ZONE_DNS
          value: "${TEST_ZONE_DNS}"
        - name: TEST_SUBSCRIPTION_1
          value: "${TEST_SUBSCRIPTION_1}"
        - name: TEST_SUBSCRIPTION_2
          value: "${TEST_SUBSCRIPTION_2}"
        - name: IDENTITY_MODE
          value: "msi-clientid"
        - name: IDENTITY_ID_1
          value: "${IDENTITY_ID_1}"
        - name: IDENTITY_ID_2
          value: "${IDENTITY_ID_2}"
}
EOF

$@
