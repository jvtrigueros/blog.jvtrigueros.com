# blog.jvtrigueros.com
Blog.

# notes

## Install Node.js 4.2 LTS
```
curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
apt-get install -y nodejs
```

## Install Ghost
```
curl -L https://github.com/TryGhost/Ghost/releases/download/0.11.4/Ghost-0.11.4.zip -o ghost-0.11.4.zip
mkdir -p /var/www
unzip ghost-0.11.4.zip -d /var/www/ghost
cd /var/www/ghost && npm install --production
npm start --production
```
