## Jboss eap 7 Load Balance - Https

Nginx was used for jboss eap 7 load balance

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
  
server {
    listen       80;
    server_name  10.57.148.23;
    return 301 https://$host$request_uri; #redirect https
  }
  
server {
   listen   443 ssl;
   ssl      on;
   server_name  papirus.domain.local;
   ssl_certificate      /root/papirus/papirus.domain.local.crt;
   ssl_certificate_key  /root/papirus/papirus.domain.local.rsa;

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
