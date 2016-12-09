##nginx
mkdir nginx && cd nginx

wget https://raw.githubusercontent.com/jamtur01/dockerbook-code/master/code/5/sample/nginx/global.conf

wget https://raw.githubusercontent.com/jamtur01/dockerbook-code/master/code/5/sample/nginx/nginx.conf

##website
mkdir website && cd website

wget https://raw.githubusercontent.com/jamtur01/dockerbook-code/master/code/5/sample/website/index.html

##command
sudo docker build -t="wyb20161209/nginx:1.0" .

sudo docker run -d -P -v $PWD/website:/var/www/html/website wyb20161209/nginx:1.0 nginx
