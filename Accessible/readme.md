## Jboss eap 7 Accessible

If you're having trouble accessing jboss eap console
```xml
<interfaces>
        <interface name="management">
          <inet-address value="${jboss.bind.address.management:127.0.0.1}"/>
        </interface>
        <interface name="public">
	      <inet-address value="${jboss.bind.address:127.0.0.1}"/>
			<any-address/>        
        </interface>
</interfaces>
```

Add your ip information in the fields below

```xml
<interfaces>
        <interface name="management">
          <inet-address value="${jboss.bind.address.management:10.10.10.21}"/>
			 <!--<any-address/>--> <!--optionally-->
        </interface>
        <interface name="public">
	      <inet-address value="${jboss.bind.address:10.10.10.21}"/>
			<!--<any-address/>--> <!--optionally-->   
        </interface>
</interfaces>
```