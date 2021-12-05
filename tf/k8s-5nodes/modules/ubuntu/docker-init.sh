#! /bin/bash
sudo apt-get update
#sudo apt-get install -y apache2
#sudo systemctl start apache2
#sudo systemctl enable apache2
#echo "<h1>Azure Linux VM with Web Server</h1>" | sudo tee /var/www/html/index.html

# Install docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce

# Start the f5-demo-httpd container
cat << 'EOF' > /etc/rc.local
#!/bin/sh -e
docker run -d -p 80:80 --restart unless-stopped mutzel/all-in-one-hackazon:postinstall supervisord -n
docker run -d -p 8080:80 -p 8443:443 --restart unless-stopped -t mendhak/http-https-echo
docker run -d -it -p 8090:80 --restart unless-stopped vulnerables/web-dvwa
EOF

sh /etc/rc.local