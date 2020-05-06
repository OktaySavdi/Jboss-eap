## Jboss eap 7 Heap Size


In `domain.xml`
```xml
<server-groups>
    <server-group name="main-server-group" profile="full">
        <jvm name="default">
            <heap size="1303m" max-size="1303m"/>
            <permgen size="256m" max-size="256m"/>
        </jvm>
        <socket-binding-group ref="full-sockets"/>
    </server-group>
     ....
     ..
</server-groups>
```

**For JBoss EAP 4/5:**

Set the following flags as desired in the `JAVA_OPTS` of `run.conf` in Linux/UNIX (or `run.conf.bat` if on Windows):
```
JAVA_OPTS="$JAVA_OPTS -Xms1303m -Xmx1303m -XX:PermSize=256m -XX:MaxPermSize=256m"
```

**Individual server level**

`In host.xml :`
```xml
<server name="server-one" group="main-server-group" auto-start="true">
    <system-properties>
        <property name="org.jboss.as.logging.per-deployment" value="false"/>
    </system-properties>
    <jvm name="default">
        <heap size="2048m" max-size="2048m"/>
        <permgen size="512m" max-size="512m"/>
    </jvm>
    ....
    ..
</server>
```
