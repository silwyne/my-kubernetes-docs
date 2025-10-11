# Kubernetes Setup


## Contents
- **[prerequisites](#prerequisites)**
- **[kind Installation](#kind)**
- **[k3s Installtion](#k3s)**
- **[helm Installation](#helm)**

## prerequisites
- **docker installed**
- **kubectl installed**
- **linux-amd64**


## kind
you can replace `version` with `v0.30.0`
1. download last stable kind from github 
[link](https://github.com/kubernetes-sigs/kind/releases).
or download use this command: 
```bash
curl -Lo ./kind https://kind.sigs.k8s.io/dl/${version}/kind-linux-amd64
```

2. make it usable
```bash
# make it executable
chmod +x kind

# move to PATH
mv ./kind /usr/local/bin/kind
```

4. verify installation
```bash
kind --version
```

to setup a cluster you need to download kind images
5. pull the image:
```bash
docker pull kindest/node:v1.29.2
```

6. make a config file:
```yaml
# kind-config.yaml
# kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    image: kindest/node:v1.29.2
  - role: worker
    image: kindest/node:v1.29.2
```

6. setup the cluster
```bash
kind create cluster --name my-cluster --config kind-config.yaml
```

7. try interacting with cluster using kubectl
```bash
kubectl cluster-info --context kind-my-cluster
kubectl get nodes
```

## k3s
you can replace `version` with `v1.34.1-rc1+k3s1`
1. download k3s itself:
```bash
curl -Lo ./k3s https://github.com/k3s-io/k3s/releases/download/${version}/k3s
```

2. make it usable
```bash
# make it executable
chmod +x k3s

# move to PATH
mv ./k3s /usr/local/bin/k3s
```

3. varify k3s installation
```bash
k3s --version
```

now for full offline installation you must install `airgap` too!
so follow this instructions to install airgap.

4. Download airgap-images
```bash
curl -Lo ./k3s-airgap-images-amd64.tar.gz https://github.com/k3s-io/k3s/releases/download/${version}/k3s-airgap-images-amd64.tar.gz
```

5. Place them in the agent's image directory
```bash
sudo mkdir -p /var/lib/rancher/k3s/agent/images/
cp k3s-airgap-images-amd64.tar.zst /var/lib/rancher/k3s/agent/images/
```

Image archives are imported every time k3s starts. This is done to ensure that all the images are consistently available, even if some images have been removed or pruned since last startup. However, this delays startup as the kubelet is not started until after all archives have been processed. To alleviate this delay there is an option to only import tarballs that have changed since they were last imported, even across restarts.
6. To enable this feature, create a .cache.json file in the images directory:
```bash
touch /var/lib/rancher/k3s/agent/images/.cache.json
```

The cache file will store archive metadata as files are processed. 
Subsequent restarts of K3s will not import the images, as long as the size and modification time of the archive remains the same.


> [!WARNING]\
> When this feature is enabled, it will not be possible to ensure that all images are available every time k3s starts. If an image was removed or pruned since last startup, take manual action to reimport the image. Either:\
> - Manually import the archive with ctr image import.
> - Use touch to modify the timestamp of the archive containing the image.
> - Clear the contents of the .cache.json file, and restart k3s.


7. **To add `server` node**:
```bash
INSTALL_K3S_SKIP_DOWNLOAD=true ./install.sh
```

8. **To add additional `agents`**, do the following on each agent node:
```bash
INSTALL_K3S_SKIP_DOWNLOAD=true K3S_URL=https://<SERVER_IP>:6443 K3S_TOKEN=<YOUR_TOKEN> ./install.sh
```

## helm
you can replace `version` with `v3.12.0`
1. download it
```bash
wget "https://get.helm.sh/helm-${version}-linux-amd64.tar.gz"
```

2. extract it and use it:
```bash
tar -xvf helm-v3.12.0-linux-amd64.tar.gz
mv ./linux-amd64/helm /usr/local/bin/helm
chmod +x /usr/local/bin/helm
```

3. varify installation
```bash
helm version
```