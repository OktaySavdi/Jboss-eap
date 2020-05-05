## Jboss eap 7 SQL Configuration

The example below is an SQL datasource configuration. The datasource has been enabled, a user has been added, and validation options have been set.
```
mkdir -p /opt/jboss-eap/modules/com/microsoft/sqlserver/main/
```
```
cp sqljdbc42.jar /opt/jboss-eap/modules/com/microsoft/sqlserver/main/
```

vi /opt/jboss-eap/modules/com/microsoft/sqlserver/main/module.xml
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
vi /opt/jboss-eap/domain/configuration/domain.xml (on master)
```xml
<datasource jndi-name="java:/UPY1" pool-name="UPY1" statistics-enabled="true">
                        <connection-url>jdbc:sqlserver://10.10.10.30;DatabaseName=UPY1</connection-url>
                        <driver-class>com.microsoft.sqlserver.jdbc.SQLServerDriver</driver-class>
                        <driver>sqlserver</driver>
                        <pool>
                            <min-pool-size>10</min-pool-size>
                            <max-pool-size>20</max-pool-size>
                         </pool>
                        <security>
                            <user-name>sa</user-name>
                            <password>sa</password>
                        </security>
                        <validation>
                            <valid-connection-checker class-name="org.jboss.jca.adapters.jdbc.extensions.mssql.MSSQLValidConnectionChecker"/>
                            <background-validation>true</background-validation>
                        </validation>
</datasource>
```
```xml
<driver name="sqlserver" module="com.microsoft.sqlserver">
                        <xa-datasource-class>com.microsoft.sqlserver.jdbc.SQLServerXADataSource</xa-datasource-class>
</driver>
```

