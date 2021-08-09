# prepare system
FROM centos:7
WORKDIR /data/app
ENV LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
RUN set -e ;\
    rpmkeys --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 ;\
    yum install -y python36 python36-devel python36-pip git lsof gcc gcc-c++ make openssl-devel gmp-devel mpfr-devel libmpc-devel libaio numactl autoconf automake libtool libffi-devel ;\
    # switch user
    useradd -rm -d /home/app -s /bin/bash -g root -u 1000 app ;\
    chown -R app:root /data/app ;\
    chmod 755 /data/app
User app

# install and config fate
RUN set -e ;\
    # clone fate
    git config --global http.postBuffer 1024288000 ;\
    git clone https://github.com/FederatedAI/FATE.git fate ;\
    # prepare base virtual environment
    python3 -m venv venv ;\
    source venv/bin/activate ;\
    python3 -m pip install --no-cache-dir -U pip ;\
    python3 -m pip install --no-cache-dir -r fate/python/requirements.txt;\
    # install fate_client
    python3 -m pip install -e fate/python/fate_client ;\
    python3 -m pip install -e fate/python/fate_test ;\
    # config flow services
    sed -i 's#work_mode: 1#work_mode: 0#' fate/conf/service_conf.yaml ;\
    sed -i 's#export PYTHONPATH=#export PYTHONPATH=/data/app/fate/python#' fate/bin/init_env.sh ;\
    sed -i 's#venv=#venv=/data/app/venv#' fate/bin/init_env.sh


# expose commands
ENV PATH="/data/app/venv/bin:${PATH}"

# config clients
RUN set -e ;\
    flow init --ip 127.0.0.1 --port 9380 ;\
    pipeline init --ip 127.0.0.1 --port 9380 ;\
    fate_test ;\
    sed -i 's#path(FATE)#/data/app/fate#' /data/app/fate/python/fate_test/fate_test/fate_test_config.yaml
# start flow services
CMD ["sh", "fate/python/fate_flow/service.sh", "starting"]
