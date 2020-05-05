## Jboss eap 7 SQL Configuration

The example below is an SQL datasource configuration. The datasource has been enabled, a user has been added, and validation options have been set.

Runtime > Server groups > < select group> > view

**Jvm assignments are made for the profile**

![image](https://user-images.githubusercontent.com/3519706/81072477-dda28e00-8eee-11ea-9115-59b881dff977.png)

![image](https://user-images.githubusercontent.com/3519706/81072517-e98e5000-8eee-11ea-8564-d31fb4dfbead.png)

**Then the relevant directory is created on the servers**
```
mkdir -p /opt/jboss-eap/modules/com/microsoft/sqlserver/main/
```
**sqljdbc file is left in the relevant field**
```
cp sqljdbc42.jar /opt/jboss-eap/modules/com/microsoft/sqlserver/main/
```
**The module.xml file is created**
```
vi /opt/jboss-eap/modules/com/microsoft/sqlserver/main/module.xml
```
```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<module xmlns="urn:jboss:module:1.0" name="com.microsoft.sqlserver">
    <resources>
        <resource-root path="sqljdbc42.jar"/>
    </resources>
    <dependencies>
        <module name="javax.api"/>
        <module name="javax.transaction.api"/>
        <module name="javax.xml.bind.api"/>
    </dependencies>
</module>
```
**Configuration > Profiles > full > Datasource & Drivers > JDBC Drivers**

![image](https://user-images.githubusercontent.com/3519706/81072866-7802d180-8eef-11ea-8387-1859772800be.png)

**Driver Name** = sqlserver

**Driver Module Name** = com.microsoft.sqlserver

**Driver Class Name** =  com.microsoft.sqlserver.jdbc.SQLServerDriver

**Driver XA Datasource Class** = com.microsoft.sqlserver.jdbc.SQLServerXADataSource

![image](https://user-images.githubusercontent.com/3519706/81073320-2149c780-8ef0-11ea-8f06-47bbdf792791.png)

![image](https://user-images.githubusercontent.com/3519706/81073374-37578800-8ef0-11ea-86fa-e2bd6f453d34.png)

**Then datasource is created**

![image](https://user-images.githubusercontent.com/3519706/81073460-581fdd80-8ef0-11ea-8e3d-4a2279bcce94.png)

![image](https://user-images.githubusercontent.com/3519706/81073492-65d56300-8ef0-11ea-9bd3-5d78f9309d31.png)

**Driver Name** = sqlserver

**Driver Module Name** = com.microsoft

**Driver Class Name** =  com.microsoft.sqlserver.jdbc.SQLServerDriver

![image](https://user-images.githubusercontent.com/3519706/81073538-72f25200-8ef0-11ea-8d1e-e88e1427601f.png)

**Connection URL** =  jdbc:sqlserver://10.10.10.30;DatabaseName=UPY1

**username** = db user

**password** = password of db user

![image](https://user-images.githubusercontent.com/3519706/81073819-dda38d80-8ef0-11ea-9938-f09b0637b917.png)

![image](https://user-images.githubusercontent.com/3519706/81074102-37a45300-8ef1-11ea-902d-76eb187c29ae.png)
