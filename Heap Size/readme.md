## Jboss eap 7 Heap Size


`host-master.xml` and `host-slave.xml` 
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
		<jvm name="member3">
            <heap size="1024m" max-size="1024m"/>
            <jvm-options>
                <option value="-server"/>
                <option value="-XX:MetaspaceSize=96m"/>
                <option value="-XX:MaxMetaspaceSize=256m"/>
            </jvm-options>
        </jvm>
		<jvm name="member4">
            <heap size="1024m" max-size="1024m"/>
            <jvm-options>
                <option value="-server"/>
                <option value="-XX:MetaspaceSize=96m"/>
                <option value="-XX:MaxMetaspaceSize=256m"/>
            </jvm-options>
        </jvm>
</jvms>
```

