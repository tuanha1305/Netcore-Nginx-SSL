# Netcore-Nginx-SSL

## 1. Introduction
Sample deploy dotnet (dotnet + nginx + pm2) on Ubuntu
## 2. Setup env
### 2.1. Install .net ubuntu
```bash
wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt update
sudo apt install apt-transport-https
sudo apt install dotnet-sdk-7.0
```
Check installed dotnet, you can exec cmd:
```bash
dotnet --list-sdks
```
Check version dotnet
```bash
dotnet --version
```
## 3. Build
First, we clone project from git.
```bash
git clone https://github.com/tuanictu97/Netcore-Nginx-SSL AspNetCoreApp
```
```bash
cd ./AspNetCoreApp
```
Next, build sample project
```bash
sudo dotnet publish --configuration Release -o /var/www/AspNetCoreApp
```
## 4. Deploy
First, we install nvm & pm2
```bash
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
# export path nvm
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
# install node
nvm install v16
```
Next, we install pm2 and lauch service dot net
```bash
npm install pm2 -g
# run 
pm2 run ecosytem.config.js
```

Finaly, we config nginx + ssl
create file ```/etc/nginx/conf.d/domain.conf``` 
```nginx
server {
        listen 80;
        server_name domain.com www.domain.com;
        rewrite ^(.*) https://domain.com$1 permanent;
}
server {
    listen 443 ssl;

    server_name domain.com;
    # SSL file. You change cert path
    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/private.pem;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers on;

    location / {
        proxy_pass         http://127.0.0.1:5000;
        proxy_http_version 1.1;
        proxy_set_header   Upgrade $http_upgrade;
        proxy_set_header   Connection keep-alive;
        proxy_set_header   Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto $scheme;
    }
}
```
Check config & restart service nginx
```bash
# test new config
nginx -t
# restart service
service nginx restart
```