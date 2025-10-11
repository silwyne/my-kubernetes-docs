# LXC


## Explanation
The closest way to run a lightweight "VM-like" environment on Debian without installing extra traditional virtualization tools is to use Linux containers (LXC). LXC uses kernel namespaces for isolation, including network namespaces that allow assigning a different IP address to the container, effectively behaving like a separate VM but with much less overhead.

With LXC, you can create a container that has its own isolated filesystem, processes, users, and network stack (including its own IP). You can then run an SSH server inside that container, allowing you to ssh into it and work as if it were a separate machine.

Key points:
  - LXC is integrated with the Linux kernel and usually available by default or with minimal installation (typically just the lxc package).
  - It creates lightweight containers using namespaces instead of full hardware virtualization.
  - You can assign network namespaces and bridge or NAT to get a different IP address.
  - Once the container is running, you can ssh into it just like a separate VM.
  - No full VM hypervisor installation needed (like KVM or VirtualBox).
  - On Debian, you can create and start containers with commands like lxc-create and lxc-start.
Another more native but heavier tool is systemd-nspawn which can also run containerized environments with isolated namespaces, including networking.

So yes, in Debian, using LXC (or systemd-nspawn) you can run a lightweight VM-like environment, isolated with its own IP, that you can ssh into and interact with, without needing traditional VM software or heavy installations.


## Installation Guide
1. install it 
```bash
sudo apt install lxc
```

2. varify installtion
```bash
lxc-create --version
```

3. create an LXC container
Use the download template to get a pre-built Debian image. Replace container1 with your desired container name:
This downloads a Debian Bookworm container root filesystem.
**ONLINE WAY**
```bash
sudo lxc-create -n container1 -t download -- --dist debian --release bookworm --arch amd64
```

**OFLINE WAY**
- first download these files from one of linux distributions 
[here](https://images.linuxcontainers.org/images)\
link for [debian 12 bookworm](https://images.linuxcontainers.org/images/debian/bookworm/)
    - rootfs.tar.xz
    - meta.tar.xz
- now run this command:
```bash
sudo lxc-create -n container1 -t local -- -m meta.tar.xz -f rootfs.tar.xz
```


4. Start the container
```bash
sudo lxc-start -n container1
```

5. Attach to the container shell
To get an interactive shell inside the container:
```bash
sudo lxc-attach -n container1
```
Now you can run commands inside the container.


## Commands

### Listing
To list running LXC containers on your Debian system, you can use the following command:
This shows only the currently running containers.
```bash
sudo lxc-ls --running
```

Alternatively, to get a more detailed, column-based list with container names, states, and IPs, use:
```bash
sudo lxc-ls --fancy
```

For just a simple list of running container names, one per line:
```bash
sudo lxc-ls --running -1
```

## K3s Installation Tip
for setting up k3s nodes in a `lxc container` you must make sure container has access to `/dev/kmsg` because k3s needs it. 

for that run this in container:
```bash
#!/bin/sh -e
# Kubeadm 1.15 needs /dev/kmsg to be there, but it's not in lxc, but we can just use /dev/console instead
# see: https://github.com/kubernetes-sigs/kind/issues/662
if [ ! -e /dev/kmsg ]; then
    ln -s /dev/console /dev/kmsg
fi
```

Then run this:
```bash
chmod +x /etc/rc.local
reboot
```

finally you can setup k3s there:
```bash

cp k3s /usr/local/bin/
chmod +x /usr/local/bin/k3s
INSTALL_MODE="WORKER"
# INSTALL_MODE="SERVER" if you want to set setup master node

# put airgap images there
mkdir -p /var/lib/rancher/k3s/agent/images/
cp k3s-airgap-images-amd64.tar.zst /var/lib/rancher/k3s/agent/images/
# mark it
touch /var/lib/rancher/k3s/agent/images/.cache.json

# put mirrors
mkdir -p /etc/rancher/k3s/
cat > /etc/rancher/k3s/registries.yaml << EOF
mirrors:
  docker.cache.ir:
    endpoint:
      - "https://docker.ache.ir"

configs:
  docker.cache.ir:
    auth:
      username: username
      password: password
EOF

# lunch node
if [ $INSTALL_MODE = "SERVER" ]; then
  # To add server node
  INSTALL_K3S_SKIP_DOWNLOAD=true ./install.sh
elif [ $INSTALL_MODE = "WORKER" ]; then
  # To add additional agents
  INSTALL_K3S_SKIP_DOWNLOAD=true K3S_URL=https://<SERVER_IP>:6443 K3S_TOKEN=<YOUR_TOKEN> ./install.sh
else
  echo "Error: ${INSTALL_MODE} as install mode is not valid (SERVER/WORKER) valid options"
  exit 0
fi
```

## Set Static IPv4
each time you reboot the lxc container it gets a new ipv4 if not set statically.
to avoid that set a static ipv4 here `10.0.3.92`:
```bash
# enter the container
sudo lxc-attach -n <container>

# set static ipv4
sudo cat > /etc/systemd/network/eth0.network << EOF
[Match]
Name=eth0

[Network]
Address=10.0.3.92/24
Gateway=10.0.3.1
EOF
```