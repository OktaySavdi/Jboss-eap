## Jboss eap 7 Oracle Configuration

The example below is an Oracle datasource configuration. The datasource has been enabled, a user has been added, and validation options have been set.
```
mkdir -p /opt/jboss-eap/modules/oracle/jdbc/main
```
```
cp ojdbc6.jar /opt/jboss-eap/modules/oracle/jdbc/main
```

vi /opt/jboss-eap/modules/oracle/jdbc/main/module.xml
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
vi /opt/jboss-eap/domain/configuration/domain.xml (on master)
```xml
<datasource jndi-name="java:/OracleDS" pool-name="OracleDS" statistics-enabled="true">
                        <connection-url>jdbc:oracle:thin:@10.10.10.30:1521:test</connection-url>
                        <driver-class>oracle.jdbc.driver.OracleDriver</driver-class>
                        <driver>oracle</driver>
						<pool>
                            <min-pool-size>10</min-pool-size>
                            <max-pool-size>20</max-pool-size>
                        </pool>
                        <security>
                            <user-name>sa</user-name>
                            <password>sa</password>
                        </security>
                        <validation>
                            <valid-connection-checker class-name="org.jboss.jca.adapters.jdbc.extensions.oracle.OracleValidConnectionChecker"/>
                            <background-validation>true</background-validation>
                            <stale-connection-checker class-name="org.jboss.jca.adapters.jdbc.extensions.oracle.OracleStaleConnectionChecker"/>
                            <exception-sorter class-name="org.jboss.jca.adapters.jdbc.extensions.oracle.OracleExceptionSorter"/>
                        </validation>
</datasource>
```
```xml
<driver name="oracle" module="oracle.jdbc">
                            <xa-datasource-class>oracle.jdbc.xa.client.OracleXADataSource</xa-datasource-class>
</driver>
```
