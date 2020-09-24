## Jboss eap 7 RBAC

![image](https://user-images.githubusercontent.com/3519706/81079915-d97b6e00-8ef8-11ea-9a83-f6045fa53719.png)

**New users are created**
```
/opt/jboss-eap/bin/add-user.sh -m -u 'oktay' -p 'oktay'
```
```
/opt/jboss-eap/bin/add-user.sh -u 'oktay' -p 'oktay' -g 'dev'
```
or
```
/opt/jboss-eap/bin/add-user.sh 
```
```
a) Management User (mgmt-users.properties)
Username : dev
Username : mon
Username : admin 
Username : super
Username : operator
```

**provider rbac is set**
```
/opt/jboss-eap/bin/jboss-cli.sh --connect --controller=10.10.10.20:9990
```
```
/core-service=management/access=authorization:write-attribute(name=provider,value=rbac)
```
**Then, if there is no role, it is added. If this step can be passed**
```sh
/core-service=management/access=authorization/role-mapping=Administrator:add()
/core-service=management/access=authorization/role-mapping=Deployer:add()
/core-service=management/access=authorization/role-mapping=Maintainer:add()
/core-service=management/access=authorization/role-mapping=Monitor:add()
/core-service=management/access=authorization/role-mapping=Operator:add()
/core-service=management/access=authorization/role-mapping=SuperUser:add()
```
**Standard Role Names** `Monitor`,`Operator`,`Maintainer`,`Deployer`,`Administrator`,`Auditor`,`SuperUser`

**The user created is authorized**
```
/core-service=management/access=authorization/role-mapping=Monitor/include=user-mon:add(name=mon,type=USER)
/core-service=management/access=authorization/role-mapping=Deployer/include=user-dev:add(name=dev,type=USER)
/core-service=management/access=authorization/role-mapping=Administrator/include=user-admin:add(name=admin,type=USER)
/core-service=management/access=authorization/role-mapping=SuperUser/include=user-admin:add(name=admin,type=USER)
/core-service=management/access=authorization/role-mapping=Operator/include=user-operator:add(name=operator,type=USER)
```
**To add the role to the created group**
```
/core-service=management/access=authorization/role-mapping=Monitor/include=group-LDAP_MONITORS:add(name=LDAP_MONITORS, type=GROUP)
```
**Method 2 manually add to `domain.xml` file**
```
vi /opt/jboss-eap/domain/configuration/domain.xml
```
```xml
<access-control provider="rbac">
            <role-mapping>
                <role name="SuperUser">
                    <include>
                        <user name="$local"/>
                        <user name="admin"/>
                        <user name="super"/>
                    </include>
                </role>
                <role name="Monitor">
                    <include>
                        <user name="dev"/>
                    </include>
                </role>
                <role name="Administrator">
                    <include>
                        <user name="admin"/>
                    </include>
                </role>
                <role name="Deployer">
                    <include>
                        <user name="mon"/>
                    </include>
                </role>
                <role name="Auditor"/>
                <role name="Operator">
                    <include>
                        <user name="operator"/>
                    </include>
                </role>
                <role name="Maintainer"/>
            </role-mapping>
</access-control>
```
