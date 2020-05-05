## Jboss eap 7 Deploy

Connect to console
```
/opt/jboss-eap/bin/jboss-cli.sh --connect
/opt/jboss-eap/bin/jboss-cli.sh --connect --controller=10.10.10.20:9990
```

**Deployment**
```
deployment deploy-file /opt/UNIGWClient.war
```
```
deploy --name=URLTester.war --server-groups=main-server-group
```
**Undeployment**
```
deployment undeploy UNIGWClient.war
```
```
undeploy --name=URLTester.war --server-groups=main-server-group
```
**List**
```
deployment list
```
```
deployment-info --server-group=main-server-group
```
**Command**
```
cp /opt/UNIGWClient.war /opt/jboss-eap/standalone/deployments/
```
```
rm /opt/jboss-eap/standalone/deployments/UNIGWClient.war
```

## HTTP Api

**Deploy**
```
curl --digest -L -D - http://<host>:<port>/management --header "Content-Type: application/json" -d '{"operation" : "composite", "address" : [], "steps" : [{"operation" : "add", "address" : {"deployment" : "<runtime-name>"}, "content" : [{"url" : "file:<path-to-archive>}]},{"operation" : "deploy", "address" : {"deployment" : "<runtime-name>"}}],"json.pretty":1}' -u <user>:<pass>
```
**Example:**
```
curl --digest -L -D - http://localhost:9990/management --header "Content-Type: application/json" -d '{"operation" : "composite", "address" : [], "steps" : [{"operation" : "add", "address" : {"deployment" : "UNIGWClient.war"}, "content" : [{"url" : "file:/opt/example/UNIGWClient.war"}]},{"operation" : "deploy", "address" : {"deployment" : "UNIGWClient.war"}}],"json.pretty":1}' -u admin:Maps2019
```

**Undeploy**
```
curl --digest -L -D - http://<host>:<port>/management --header "Content-Type: application/json" -d '{"operation" : "composite", "address" : [], "steps" : [{"operation" : "undeploy", "address" : {"deployment" : "<runtime-name>"}},{"operation" : "remove", "address" : {"deployment" : "<runtime-name>"}}],"json.pretty":1}' -u <user>:<pass>
```
**Example:**
```
curl --digest -L -D - http://localhost:9990/management --header "Content-Type: application/json" -d '{"operation" : "composite", "address" : [], "steps" : [{"operation" : "undeploy", "address" : {"deployment" : "example.war"}},{"operation" : "remove", "address" : {"deployment" : "example.war"}}],"json.pretty":1}' -u user:password
```