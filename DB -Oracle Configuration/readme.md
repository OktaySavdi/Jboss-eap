## Jboss eap 7 Oracle Configuration

Runtime > Server groups > < select group> > view

**Jvm assignments are made for the profile**

![image](https://user-images.githubusercontent.com/3519706/81072477-dda28e00-8eee-11ea-9115-59b881dff977.png)

![image](https://user-images.githubusercontent.com/3519706/81072517-e98e5000-8eee-11ea-8564-d31fb4dfbead.png)

**Then the relevant directory is created on the servers**
```
mkdir -p /opt/jboss-eap/modules/oracle/jdbc/main
```
**sqljdbc file is left in the relevant field**
```
cp ojdbc6.jar /opt/jboss-eap/modules/oracle/jdbc/main/
```
**The module.xml file is created**
```
vi /opt/jboss-eap/modules/oracle/jdbc/main/module.xml
```
```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<module xmlns="urn:jboss:module:1.0" name="oracle.jdbc">
    <resources>
        <resource-root path="ojdbc6.jar"/>
    </resources>
    <dependencies>
        <module name="javax.api"/>
        <module name="javax.transaction.api"/>
    </dependencies>
</module>
```
**Configuration > Profiles > full > Datasource & Drivers > JDBC Drivers**

![image](https://user-images.githubusercontent.com/3519706/81072866-7802d180-8eef-11ea-8387-1859772800be.png)

**Driver Name** = oracle

**Driver Module Name** = oracle.jdbc

**Driver XA Datasource Class** = oracle.jdbc.xa.client.OracleXADataSource

![image](https://user-images.githubusercontent.com/3519706/81075827-83f09280-8ef3-11ea-8987-bd40cc4a7f7c.png)

![image](https://user-images.githubusercontent.com/3519706/81075901-a1bdf780-8ef3-11ea-8862-537fcb2c679b.png)

**Then datasource is created**

![image](https://user-images.githubusercontent.com/3519706/81075991-c1552000-8ef3-11ea-8b39-d7421158d2c7.png)

![image](https://user-images.githubusercontent.com/3519706/81076054-d5008680-8ef3-11ea-952f-e00d5cd14b6f.png)

**Driver Name** = oracle

**Driver Module Name** = oracle.jdbc

**Driver Class Name** =  oracle.jdbc.driver.OracleDriver

![image](https://user-images.githubusercontent.com/3519706/81076215-12651400-8ef4-11ea-8335-c2b58f2d9dc0.png)


**Connection URL** =  jdbc:oracle:thin:@10.10.10.30:1521:vtstest

**username** = db user

**password** = password of db user

![image](https://user-images.githubusercontent.com/3519706/81076778-bea6fa80-8ef4-11ea-9564-80643c53fd7d.png)

![image](https://user-images.githubusercontent.com/3519706/81076822-cebeda00-8ef4-11ea-8676-90b837f694cd.png)
