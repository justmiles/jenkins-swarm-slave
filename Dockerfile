FROM openjdk:8-jdk

ENV JENKINS_SWARM_VERSION 3.7

ENV HOME /home/jenkins

ENV EXECUTORS 1

ENV JENKINS_MASTER http://jenkins:8080

ENV JENKINS_USERNAME admin

ENV JENKINS_PASSWORD password

ENV SLAVE_TUNNEL_PORT 50000

ENV ECS_CLUSTER_NAME ops

RUN apt-get update && apt-get install -y net-tools make && rm -rf /var/lib/apt/lists/*

RUN useradd -c "Jenkins Slave user" -d $HOME -m jenkins

RUN curl --create-dirs -o /usr/share/jenkins/swarm-client.jar \
  https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/$JENKINS_SWARM_VERSION/swarm-client-$JENKINS_SWARM_VERSION.jar \
  && chmod 755 /usr/share/jenkins \
  && curl -L https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 -o /usr/bin/jq \
  && chmod +x /usr/bin/jq \
  && curl -s -O https://s3.amazonaws.com/aws-cli/awscli-bundle.zip \
  && unzip awscli-bundle.zip \
  && ./awscli-bundle/install -i /usr/local/aws -b /usr/bin/aws \
  && rm -rf ./awscli-bundle awscli-bundle.zip \
  && curl https://releases.rancher.com/install-docker/17.05.sh | sh \
  && rm -rf /var/lib/apt/lists/* \
  && groupadd ecsdocker --gid 497 \
  && usermod -aG ecsdocker jenkins \
  && usermod -aG docker jenkins

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

USER jenkins

VOLUME /home/jenkins

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
