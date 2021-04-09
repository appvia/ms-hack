# MS-HACK

This repo represents work done during a [Micorosft Open Hack](https://openhack.microsoft.com/) event.

It demonstrates the ability to associate two AD POD Identies with a single POD and programatically authenticate dynamically to the corrsct identity.

### Pre-requisites

1. Install Docker
1. Install Kubectl
1. Ensure you have an AKS cluster with the feature "Azure Active Directory pod Identities" enabled. You can follow steps [Azure Active Directory pod](https://docs.microsoft.com/en-us/azure/aks/use-azure-ad-pod-identity#create-an-identity).


### Build

1. Build and push container image

    ```
    # set a suitable repo here
    export REPO=quay.io/appvia
    make image
    make push-image

### Run

1. First create two MSI identities in Azure:
    ```
    ./hack.sh create-id id-1 kore-msidentityhack-aks-dev-infra-uksouth
    ./hack.sh create-id id-2 kore-msidentityhack-aks-dev-infra-uksouth
    ```

1. Now apply these identities to a cluster
    ```
    ./hack.sh apply-id id-1 kore-msidentityhack-aks-dev-infra-uksouth
    ./hack.sh apply-id id-1 kore-msidentityhack-aks-dev-infra-uksouth
    ```

1. Finally run the workload
    ```
    ./hack.sh deploy \
      kore-msidentityhack-aks-dev-infra-uksouth \
      horse.appvia.io \
      kore-msidentityhack-aks-dev-infra-uksouth \
      id-1 \
      id-2 \
      18e41964-4477-47e4-b5c0-bfef3724b4b8 \
      0fe8ae6c-8466-4a1e-8a65-80403a6c1b9f
    ```
