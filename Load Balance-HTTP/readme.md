## Jboss eap 7 Load Balance - Http

Nginx was used for jboss eap 7 loadbalance

```
upstream unig {
    server 10.10.10.20:8080;
    server 10.10.10.21:8080;
    server 10.10.10.22:8080;
  }

  upstream urltest {
    server 10.10.10.20:8230;
    server 10.10.10.21:8230;
    server 10.10.10.22:8230;
  }

server {
    listen       80;
    server_name  10.10.10.23;
  
  location /UNIGWClient {
        proxy_pass      http://unig;
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
      }

  location /URLTester {
        proxy_pass      http://urltest;
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
      }

      error_page   500 502 503 504  /50x.html;
      location = /50x.html {
          root   /usr/share/nginx/html;
    }
}
```
