## Jboss eap 7 SSL

**Go to the relevant directory**
```ruby
cd /opt/jboss-eap/domain/configuration/
```
**Keystore is created**
```ruby
keytool -genkey -alias papirus -keyalg RSA -keysize 2048 -validity 365 -keystore application.keystore -keypass secret -storepass changeit -srcstoretype PKCS12
```
**Created alias named papirus is deleted**
```ruby
keytool -delete -alias papirus -keystore application.keystore -storepass changeit
```
**Make sure the keystore is empty**
```ruby
keytool -list -v -keystore /opt/jboss-eap/domain/configuration/application.keystore -storepass changeit
```
**Convert the x.509 cert and key to a pkcs12 file**
```ruby
openssl pkcs12 -export -in /root/papirus/papirus.mydomain.local.crt -inkey /root/papirus/papirus.mydomain.local.rsa \
               -out papirus.p12 -name papirus \
               -CAfile /root/papirus/ca.crt -caname root
Enter Export Password: password
Verifying - Enter Export Password: password
```
**Convert the pkcs12 file to a Java keystore**
```ruby
keytool -importkeystore \
        -deststorepass changeit -destkeypass changeit -destkeystore application.keystore \
        -srckeystore /opt/jboss-eap/domain/configuration/papirus.p12 -srcstoretype PKCS12 -srcstorepass password \
        -alias papirus
```
**Check that the certificate is imported**
```ruby
keytool -list -keystore application.keystore -storepass changeit -v
```
keystore moves to other machines
```ruby
scp application.keystore root@10.10.10.21:/opt/jboss-eap/domain/configuration
```
**Go to the files `host-master.xml` and `host-slave.xml`. keystore-password, key-password and Alias field are changed**
```xml
<ssl>
      <keystore path="application.keystore" relative-to="jboss.domain.config.dir" keystore-password="changeit" alias="papirus" key-password="changeit" generate-self-signed-certificate-host="localhost"/>
</ssl>
```
**Make sure that the domain.xml file has https inside the undertow field.**
```xml
<https-listener name="https" socket-binding="https" security-realm="ApplicationRealm" enable-http2="true"/>
```
**Services are restarted**
```
systemctl restart jboss-eap-rhel
```
