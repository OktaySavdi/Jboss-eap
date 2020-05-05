## Jboss eap 7 vault


**Create Vault Keystore**
```
mkdir /opt/jboss-eap/vault
chown -R jboss-eap:jboss-eap /opt/jboss-eap/vault/
```
```
keytool -genseckey -alias vault -storetype jceks -keyalg AES -keysize 128 -storepass vault22 -keypass vault22 -validity 730 -keystore /opt/jboss-eap/vault/vault.keystore
```
**Set encrypt db password**
```
/opt/jboss-eap/bin/vault.sh --keystore /opt/jboss-eap/vault/vault.keystore --keystore-password vault22 --alias vault --vault-block upy1 --attribute password --sec-attr MyPassword --enc-dir /opt/jboss-eap/vault/ --iteration 120 --salt 1234abcd
```
**salt**               -> It is a random eight-character string used with the number of iterations to encrypt the contents of the keystore.
**Vault Block**  -> The name to be given to this block in the password vault.
**Attribute**     -> Name to be stored attribute
**SEC-ATTR**  -> Password stored in the password vault.
**iteration**   -> Number of operations of the encryption algorithm.

After running, the following screens will come
```
********************************************
Vault Block:vb
Attribute Name:password
Configuration should be done as follows:
VAULT::upy1::password::1 !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

For domain mode:
/host=the_host/core-service=vault:add(vault-options=
[("KEYSTORE_URL" => "/opt/jboss-eap/vault/vault.keystore"),
("KEYSTORE_PASSWORD" => "MASK-5dabcYfCSd"),("KEYSTORE_ALIAS" 
=> "vault"),("SALT" => "1234abcd"),("ITERATION_COUNT" => 
"120"),("ENC_FILE_DIR" => "/opt/jboss-eap/vault/")])
```
**Copy vault folder all server**
```
scp -r /opt/jboss-eap/vault root@10.10.10.21:/opt/jboss-eap/vault
chown -R jboss-eap:jboss-eap /opt/jboss-eap/vault/
```

**Commands are added to the relevant fields(host-master.xml and host-slave.xml)**
```xml
</extensions>
<vault>
  <vault-option name="KEYSTORE_URL" value="/opt/jboss-eap/vault/vault.keystore"/>
  <vault-option name="KEYSTORE_PASSWORD" value="MASK-5dabcYfCSd"/>
  <vault-option name="KEYSTORE_ALIAS" value="vault"/>
  <vault-option name="SALT" value="1234abcd"/>
  <vault-option name="ITERATION_COUNT" value="120"/>
  <vault-option name="ENC_FILE_DIR" value="/opt/jboss-eap/vault/"/>
</vault>
```
**Then, the password information generated is changed through the configuration.**
```
vi /opt/jboss-eap/domain/configuration/domain.xml
```
previous
```xml
<security>
    <user-name>sa</user-name>
    <password>sa</password>
</security>
```
modified version
```xml
<security>
    <user-name>sa</user-name>
    <password>${VAULT::vb::password::1}</password>
</security>
```