## Jboss eap 7 Module

![image](https://user-images.githubusercontent.com/3519706/81080089-07f94900-8ef9-11ea-8912-10093cf44cca.png)

```
/opt/jboss-eap/bin/jboss-cli.sh --connect
/opt/jboss-eap/bin/jboss-cli.sh --connect --controller=10.57.148.20:9990
/opt/jboss-eap/bin/jboss-cli.sh --connect --controller=10.57.148.20:9990 -gui
```
**Add module**
```
module add --name=com.sqlserver --resources=/opt/sqljdbc42.jar --dependencies=javax.api,javax.transaction.api,javax.xml.bind.api
```
**Add global module**
```
/subsystem=ee:list-add(name=global-modules,value={name=com.sqlserver})
```

**Check Module**
```
ll /opt/jboss-eap/modules/com/sqlserver/main/
```
