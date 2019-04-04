FROM quay.io/operator-framework/ansible-operator:v0.6.0
USER root
RUN pip install etcd3
RUN pip install boto3
RUN pip install botocore

USER ${USER_UID}

COPY roles/ ${HOME}/roles/
COPY playbook.yaml ${HOME}/playbook.yaml
COPY backup_playbook.yaml ${HOME}/backup_playbook.yaml
COPY restore_playbook.yaml ${HOME}/restore_playbook.yaml
COPY watches.yaml ${HOME}/watches.yaml