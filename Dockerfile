FROM quay.io/water-hole/ansible-operator:latest
USER root
RUN yes | pip uninstall ansible
RUN pip install etcd3
RUN pip install ansible https://github.com/alaypatel07/ansible/archive/devel.tar.gz
USER ${USER_UID}

#COPY ansible/ /opt/ansible/
#COPY config.yaml /opt/ansible/config.yaml

COPY ansible/roles/ ${HOME}/roles/
COPY ansible/playbook.yaml ${HOME}/playbook.yaml
COPY config.yaml ${HOME}/watches.yaml
