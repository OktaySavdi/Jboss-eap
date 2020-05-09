FROM registry.redhat.io/jboss-eap-7/eap72-openshift

ENV JBOSS_USER=jbosseap
ENV JBOSS_HOME /opt/eap
ENV JBOSS_Deploy=webapp.war
ENV EAP_Module /opt/eap/modules/com/microsoft/sqlserver

# Install sqlserver module
RUN mkdir -p ${EAP_Module}/main/
ADD sqljdbc42.jar ${EAP_Module}/main/
ADD module.xml ${EAP_Module}/main/

USER root

# add a user for the application, with sudo permissions
RUN groupadd -r $JBOSS_USER -g 433 && \
useradd -u 431 -r -g $JBOSS_USER -d ${JBOSS_HOME} -s /sbin/nologin -c "$JBOSS_USER user" $JBOSS_USER && \
chown -R $JBOSS_USER:$JBOSS_USER ${JBOSS_HOME}

# Specify default values for entry point
RUN ${JBOSS_HOME}/bin/add-user.sh admin admin --silent && rm -rf ${JBOSS_HOME}/standalone/deployments/*

# configure JBoss
RUN echo "JAVA_OPTS=\"\$JAVA_OPTS -Djboss.bind.address=0.0.0.0 -Djboss.bind.address.management=0.0.0.0\"" >> $JBOSS_HOME/bin/standalone.conf

# JBoss ports
EXPOSE 8080 9990 9999

# start JBoss
ENTRYPOINT ${JBOSS_HOME}/bin/standalone.sh -c standalone-full.xml

# deploy app
COPY $JBOSS_Deploy $JBOSS_HOME/standalone/deployments/
RUN chown -R $JBOSS_USER:$JBOSS_USER ${JBOSS_HOME}/standalone/deployments/

USER $JBOSS_USER
CMD /bin/bash