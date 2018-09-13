FROM quay.io/water-hole/ansible-operator:latest
USER root
#RUN yes | pip uninstall ansible
RUN pip install etcd3
#RUN pip install ansible https://github.com/alaypatel07/ansible/archive/devel.tar.gz
COPY etcd-modules/etcd_member.py /lib/python2.7/site-packages/ansible/modules/database/etcd/
COPY etcd-modules/etcd_member_lookup.py /lib/python2.7/site-packages/ansible/plugins/lookup/etcd_member.py
USER ${USER_UID}

COPY ansible/roles/ ${HOME}/roles/
COPY ansible/playbook.yaml ${HOME}/playbook.yaml
COPY config.yaml ${HOME}/watches.yaml
