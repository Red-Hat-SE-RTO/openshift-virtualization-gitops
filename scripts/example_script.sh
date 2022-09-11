#!/bin/bash
# example example_script.sh isntall-type kcli-openshift4-baremetal-dsal "http://yourrepo:3000/tosin/openshift-virtualization-gitops.git svc-gitea CHANGEME"

function qubinode-installer(){
# Change Git URL to your Git Repo
cat  >/root/.fetchit/config.yaml<<EOF
targetConfigs:
- url: ${GITURL}
  username: ${GIT_USERNAME}
  password: ${GIT_PASSWORD}
  filetransfer:
  - name: copy-vars
    targetPath: inventories/${DIRECTORY_PATH}/host_vars
    destinationDirectory: /home/admin/qubinode-installer/playbooks/vars
    schedule: "*/1 * * * *"
  branch: main
EOF
}

function kcli-openshift4-baremetal(){
# Change Git URL to your Git Repo
cat  >/root/.fetchit/config.yaml<<EOF
targetConfigs:
- url: ${GITURL}
  username: ${GIT_USERNAME}
  password: ${GIT_PASSWORD}
  filetransfer:
  - name: copy-vars
    targetPath: inventories/${DIRECTORY_PATH}/paramfiles
    destinationDirectory: /root/kcli-openshift4-baremetal/paramfiles
    schedule: "*/1 * * * *"
  branch: main
EOF
}

function kcli-openshift4-baremetal-lab(){
# Change Git URL to your Git Repo
cat  >/root/.fetchit/config.yaml<<EOF
targetConfigs:
- url: ${GITURL}
  username: ${GIT_USERNAME}
  password: ${GIT_PASSWORD}
  filetransfer:
  - name: copy-vars
    targetPath: inventories/${DIRECTORY_PATH}/paramfiles
    destinationDirectory: /root/kcli-openshift4-baremetal/paramfiles
    schedule: "*/1 * * * *"
  branch: main
  - name: qubinode-installer
    targetPath: inventories/${DIRECTORY_PATH}/host_vars
    destinationDirectory: /home/admin/qubinode-installer/playbooks/vars
    schedule: "*/1 * * * *"
  branch: main
EOF
}

function openshift-4-deployment-notes(){
# Change Git URL to your Git Repo
cat  >/root/.fetchit/config.yaml<<EOF
targetConfigs:
- url: ${GITURL}
  username: ${GIT_USERNAME}
  password: ${GIT_PASSWORD}
  filetransfer:
  - name: copy-vars
    targetPath: inventories/${DIRECTORY_PATH}/host_vars
    destinationDirectory: /home/admin/openshift-4-deployment-notes/assisted-installer
    schedule: "*/1 * * * *"
  branch: main
EOF
}

function openshift-aio(){
# Change Git URL to your Git Repo
cat  >/root/.fetchit/config.yaml<<EOF
targetConfigs:
- url: ${GITURL}
  username: ${GIT_USERNAME}
  password: ${GIT_PASSWORD}
  filetransfer:
  - name: copy-vars
    targetPath: inventories/${DIRECTORY_PATH}/host_vars
    destinationDirectory: /root/openshift-aio
    schedule: "*/1 * * * *"
  branch: main
EOF
}

if [ $# -ne 5 ]; then
    echo "Usage: $0 <qubinode-installer|kcli-openshift4-baremetal|kcli-openshift4-baremetal-lab|openshift-4-deployment-notes|openshift-aio> <directory_path> <git_url> <git_username> <git_password>"
    exit 1
fi

INSTALL_TYPE=$1
DIRECTORY_PATH=$2
GITURL=$3
GIT_USERNAME=$4
GIT_PASSWORD=$5

if [ ! -d $HOME/openshift-virtualization-gitops ];
then
    git clone $GITURL
fi

if [ ! -d $HOME/openshift-virtualization-gitops/inventories/${DIRECTORY_PATH} ];
then
    echo "${1} Directory does not exist please validate it exists and try again"
    exit 1
fi

systemctl enable podman.socket --now
mkdir -p /opt/fetchit
mkdir -p ~/.fetchit

case $INSTALL_TYPE in

  qubinode-installer)
    qubinode-installer
    ;;

  kcli-openshift4-baremetal)
    kcli-openshift4-baremetal
    ;;

  kcli-openshift4-baremetal-lab)
    kcli-openshift4-baremetal-lab
    ;;

  openshift-4-deployment-notes)
    openshift-4-deployment-notes
    ;;

  openshift-aio)
    openshift-aio
    ;;

  *)
    echo -n "unknown install type: ${INSTALL_TYPE}"
    exit 1
    ;;
esac


cp $HOME/openshift-virtualization-gitops/scripts/fetchit/fetchit-root.service /etc/systemd/system/fetchit.service
systemctl enable fetchit --now


