1-Creat a Service user
```sh
sudo useradd --no-create-home --shel /bin/false/ jboss-eap
```
2-Set the JBOSS_HOME and JBOSS_USER
```
sudo vim /opt/jboss-eap/bin/init.d/jboss-eap.conf
```
3-copy the service files
```
sudo cp /opt/jboss-eap/bin/init.d/jboss-eap.conf /etc/default/
sudo cp /opt/jboss-eap/bin/init.d/jboss-eap-rhel.sh /etc/init.d/
```
4-make the script executeble
```
sudo chmod +x /etc/init.d/jboss-eap-rhel.sh 
```
5-set the service to start automaticallay
```
sudo chkconfig --add jboss-eap-rhel.sh
sudo chkconfig jboss-eap-rhel.sh on 
```
6-Create the Jboss EAP's run directory and set the ownership
```
sudo mkdir /var/run/jboss-eap
sudo chown -R jboss-eap:jboss-eap /var/run/jboss-eap/
```
7-Change the ownership of the JBOSS_HOME directory
```
sudo chown -R jboss-eap:jboss-eap /opt/jboss-eap
```
8-start the service
```
systemctl start jboss-eap-rhel
```
Not:

if you selinux active
```
vim ~/selinux/jboss-eap-rhel.te
```
```
module jboss-eap-rhel 1.0;

require {
        type init_t;
		type var_log_t;
		class file create;
}
allow init_t var_log_t:file create;
```
2- create policy file from the enforcement file
```
cd ~/selinux/
sudo make -f /usr/share/selinux/devel/Makefile jboss-eap-rhel.pp
```
3-add the policy module
```
sudo semodule -i jboss-eap-rhel.pp 
```
4-start the service
```
systemctl start jboss-eap-rhel
```
