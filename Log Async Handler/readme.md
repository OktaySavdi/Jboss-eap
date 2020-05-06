## Jboss eap 7 Log Async Handler

Console > Configuration > profiles > full > Logging > Configuration > view > handler > async handler > add

![image](https://user-images.githubusercontent.com/3519706/81142833-51897880-8f79-11ea-8543-ae180bbc01c9.png)


**Level**  -> INFO

**Overflow Action** -> BLOCK

**Queue Length** -> 512

**Subhandlers** -> (pre-prepared log handler is selected)

![image](https://user-images.githubusercontent.com/3519706/81142911-80075380-8f79-11ea-9f72-0776fd4bc069.png)

Method 2

vi /opt/jboss-eap/domain/configuration/domain.xml

Added under the selected profile
```xml
<async-handler name="Async-file">
                    <level name="INFO"/>
                    <queue-length value="512"/>
                    <overflow-action value="block"/>
                    <subhandlers>
                        <handler name="size-handler"/>
                    </subhandlers>
</async-handler>
```

![image](https://user-images.githubusercontent.com/3519706/81143079-d7a5bf00-8f79-11ea-9115-a4a61fb5e720.png)
