## Jboss eap 7 Log size


Console > Configuration > profiles > full > Logging > Configuration > view > handler > size handler > add

![image](https://user-images.githubusercontent.com/3519706/81142312-03c04080-8f78-11ea-85c7-b1c65c879cf7.png)

**Name**                        ->  size-handler

**File / Path**                 ->  server.log

**File / relative To**          -> jboss.server.log.dir

**Formatter**                     -> %d{HH:mm:ss,SSS} %-5p [%c] (%t) %s%E%n

**Level**                             -> INFO            
       
**Max Backup Index**      -> 10

**Rotate Size**                  -> 100m

**Suffix**                           -> .yyyy-MM-dd

![image](https://user-images.githubusercontent.com/3519706/81142417-500b8080-8f78-11ea-8b7e-a1dfeec292e3.png)

Method 2
```
vi /opt/jboss-eap/domain/configuration/domain.xml
```
Added under the selected profile
```xml
<size-rotating-file-handler name="size-file">
                    <level name="INFO"/>
                    <formatter>
                        <pattern-formatter pattern="%d{HH:mm:ss,SSS} %-5p [%c] (%t) %s%E%n"/>
                    </formatter>
                    <file relative-to="jboss.server.log.dir" path="server.log"/>
                    <rotate-size value="100m"/>
                    <max-backup-index value="5"/>
                    <suffix value=".yyyy-MM-dd"/>
</size-rotating-file-handler>
```

![image](https://user-images.githubusercontent.com/3519706/81142699-fb1c3a00-8f78-11ea-823d-9780b92895b7.png)
