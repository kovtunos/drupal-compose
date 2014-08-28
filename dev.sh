#!/usr/bin/env bash

IMAGE=docker-registry.simpledrupalcloud.com/dev

IFS=$'\n'

install() {
  sudo apt-get install -y realpath

  SCRIPT=$(realpath -s $0)

  if [ "${SCRIPT}" = /usr/local/bin/dev ]; then
    cat << EOF
dev is already installed on this machine.

Type "dev update" to get the latest updates.
EOF
    exit
  fi

  sudo apt-get install -y curl

  curl -sSL https://get.docker.io/ubuntu/ | sudo bash

  sudo docker pull ${IMAGE}

  sudo cp ${SCRIPT} /usr/local/bin/dev
}

update() {
  CONTEXT=$(mktemp -d)

  git clone git@git.simpledrupalcloud.com:viljaste/dev.git $CONTEXT

  $CONTEXT/dev.sh install
}

init() {
  sudo docker run --rm -i -t -v $(pwd):/src ${IMAGE} init
}

up() {
  for command in $(sudo docker run --rm -a stdout -i -t -v $(pwd):/src ${IMAGE} up); do
    eval "${command}"
  done
}

down() {
  for command in $(sudo docker run --rm -a stdout -i -t -v $(pwd):/src ${IMAGE} down); do
    eval "${command}"
  done
}

destroy() {
  for command in $(sudo docker run --rm -a stdout -i -t -v $(pwd):/src ${IMAGE} destroy); do
    eval "${command}"
  done
}

yaml_dev_master_ssh_user() {
  echo $(sudo docker run --rm -a stdout -i -t -v $(pwd):/src ${IMAGE} yaml dev-master.ssh.user)
}

yaml_dev_master_ssh_hostname() {
  echo $(sudo docker run --rm -a stdout -i -t -v $(pwd):/src ${IMAGE} yaml dev-master.ssh.hostname)
}

yaml_dev_master_drupal_path() {
  echo $(sudo docker run --rm -a stdout -i -t -v $(pwd):/src ${IMAGE} yaml dev-master.drupal.path)
}

yaml_environment_exists() {
  echo $(sudo docker run --rm -a stdout -i -t -v $(pwd):/src ${IMAGE} yaml environments["${1}"])
}

ssh() {
  sudo docker run --rm -t -i -v ~/.ssh:/root/.ssh simpledrupalcloud/ssh "${@}"
}

ssh_master() {
  ssh -t "$(yaml_dev_master_ssh_user)@$(yaml_dev_master_ssh_hostname)" "cd $(yaml_dev_master_drupal_path) && exec \$SHELL -l"
}

git() {
  sudo docker run --rm -t -i -v $(pwd):/src -v ~/.gitconfig:/root/.gitconfig -v ~/.ssh:/root/.ssh simpledrupalcloud/git "${@}"
}

svn() {
  sudo docker run --rm -t -i -v $(pwd):/src -v ~/.subversion:/root/.subversion simpledrupalcloud/svn "${@}"
}

#drush() {
#  sudo docker run --rm -t -i -v $(pwd):/src simpledrupalcloud/drush "${@}"
#}
#
#drupal_fix_permissions() {
#
#}

case "${1}" in
  install)
    install
    ;;
  update)
    update
    ;;
  init)
    init
    ;;
  up)
    up
    ;;
  down)
    down
    ;;
  destroy)
    destroy
    ;;
  ssh)
    ENVIRONMENT=0

    case "${2}" in
      master)
        ssh_master
        ;;
      *)
        ssh "${@:2}"
      ;;
    esac
    ;;
  sync)
    case "${2}" in
      database)
        echo "sync database"
        ;;
      files)
        echo "file"
      ;;
    esac
    ;;
  git)
    git "${@:1}"
  ;;
  svn)
    svn "${@:1}"
  ;;
esac
