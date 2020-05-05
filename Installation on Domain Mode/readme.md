## Jboss eap 7 installation on Domain Mode

**Set name on hosts (all)**
```
vi /etc/hosts
```
```
10.10.10.20 jbosweb01 ->master
10.10.10.21 jbosweb02 ->slave1
10.10.10.22 jbosweb03 ->slave2
```
**instal JAVA (all)**
```
yum install java-11-openjdk-devel -y
```
**Get secret on master (master)**
```
/opt/jboss-eap/bin/add-user.sh 
username: admin
passwor: admin

<secret value="YWRtaW4=" />
```
**Set master name on `host-master.xml` (master)**
```xml
<host xmlns="urn:jboss:domain:11.0" name="master-jbossweb01">
```
**set accesible adress on `host-master.xml` (master)**
```xml
<interfaces>
        <interface name="management">
            <inet-address value="${jboss.bind.address.management:10.10.10.20}"/>
        </interface>
        <interface name="public">
            <inet-address value="${jboss.bind.address:10.10.10.20}"/>
        </interface>
        <interface name="unsecure">
            <inet-address value="${jboss.bind.address.unsecure:10.10.10.20}"/>
        </interface>
    </interfaces>
```
**Set slave name on `host-slave.xml` (slave1,slave2)**
```xml
<host xmlns="urn:jboss:domain:11.0" name="slave1-jbossweb02">
```
**Set master secret on `host-slave.xml` on slave machine (slave1,slave2)**
```xml
<secret value="YWRtaW4=" />
```
**Set accesible adress on `host-slave.xml` on slave machine (slave1,slave2)**
```xml
<interfaces>
        <interface name="management">
            <inet-address value="${jboss.bind.address.management:10.10.10.21}"/>
        </interface>
        <interface name="public">
            <inet-address value="${jboss.bind.address:10.10.10.21}"/>
        </interface>
</interfaces>
```
**Set username for remote connection `slave-host.xml` (slave1,slave2)**
```xml
<remote security-realm="ManagementRealm" username="admin">
```
**Set master IP for remote connection `slave-host.xml` (slave1,slave2)**
```xml
<static-discovery name="primary" protocol="${jboss.domain.master.protocol:remote+http}" host="${jboss.domain.master.address:10.10.10.20}" port="${jboss.domain.master.port:9990}"/>
```
**Set heapsize jor master and slave (all)**
```xml
<jvms>
        <jvm name="default">
            <heap size="1024m" max-size="1024m"/>
            <jvm-options>
                <option value="-server"/>
                <option value="-XX:MetaspaceSize=96m"/>
                <option value="-XX:MaxMetaspaceSize=256m"/>
            </jvm-options>
        </jvm>
</jvms>
```
**Set server-groups heap size or other configuration on `domain.xml` (all)**
```xml
<server-groups>
        <server-group name="main-server-group" profile="full">
            <jvm name="default">
                <heap size="1000m" max-size="1000m"/>
            </jvm>
            <socket-binding-group ref="full-sockets"/>
        </server-group>
        <server-group name="other-server-group" profile="full-ha">
            <jvm name="default">
                <heap size="1000m" max-size="1000m"/>
            </jvm>
            <socket-binding-group ref="full-ha-sockets"/>
        </server-group>
</server-groups>
```
**Create Service (all)**
1-Creat a Service user
```
sudo useradd --no-create-home --shel /bin/false/ jboss-eap
```
2-Set the JBOSS_HOME and JBOSS_USER
```
sudo vim /opt/jboss-eap/bin/init.d/jboss-eap.conf
```
Location of JBoss EAP
```
JBOSS_HOME="/opt/jboss-eap"
```
The username who should own the process.
```
JBOSS_USER=jboss-eap
```
The mode JBoss EAP should start, standalone or domain
```
JBOSS_MODE=domain
```
Configuration for domain mode
```
JBOSS_DOMAIN_CONFIG=domain.xml
JBOSS_HOST_CONFIG=host-slave.xml
```
3-Copy the service files
```
sudo cp /opt/jboss-eap/bin/init.d/jboss-eap.conf /etc/default/
```
```
sudo cp /opt/jboss-eap/bin/init.d/jboss-eap-rhel.sh /etc/init.d/
```
4-Make the script executeble
```
sudo chmod +x /etc/init.d/jboss-eap-rhel.sh 
```
5-Set the service to start automaticallay
```
sudo chkconfig --add jboss-eap-rhel.sh
```
```
sudo chkconfig jboss-eap-rhel.sh on 
```
6-Create the Jboss EAP's run directory and set the ownership
```
sudo mkdir /var/run/jboss-eap
```
```
sudo chown -R jboss-eap:jboss-eap /var/run/jboss-eap/
```
7-Change the ownership of the JBOSS_HOME directory
```
sudo chown -R jboss-eap:jboss-eap /opt/jboss-eap
```
8-Start the service
```
systemctl start jboss-eap-rhel
```
**if you want, you can run it without service**
```
#/opt/jboss-eap/bin/domain.sh --host-config=host-master.xml
```
```
#/opt/jboss-eap/bin/domain.sh --host-config=host-slave.xml -Djboss.domain.master.address=10.10.10.20
```
