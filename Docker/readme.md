# Deploying Applications on your Docker JBoss EAP Image

### Using docker login

Use the following command(s) from a system with docker service installed and running

```ruby
$ docker login registry.redhat.io
Username: {REGISTRY-SERVICE-ACCOUNT-USERNAME}
Password: {REGISTRY-SERVICE-ACCOUNT-PASSWORD}
Login Succeeded!

$ docker pull registry.redhat.io/jboss-eap-7/eap72-openshift
```
The build step should be done
```
docker build . -t jboss
```
container is created
```ruby
docker run -d  -p 8080:8080 -p 9990:9990 -it quay.io/oktaysavdi/jboss -b 0.0.0.0 -bmanagement 0.0.0.0
```
Application is controlled via console
```ruby
http://[ServerIP]:9990/console/index.html
```

![image](https://user-images.githubusercontent.com/3519706/81474024-89a7ea00-920b-11ea-8a91-0880e522c8f0.png)

Application is called
```ruby
http://[ServerIP]:8080/webapp/
```
![image](https://user-images.githubusercontent.com/3519706/81474092-e4d9dc80-920b-11ea-9713-1b9bde8f71f4.png)
