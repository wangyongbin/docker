https://github.com/turnbullpress/dockerbook-code/tree/master/code/5/sinatra/Dockerfile

sudo docker build -t wyb20161209/sinatra:1.0 .

wget --cut-dirs=3 -nH -r --reject Dockerfile,index.html --no-parent http://dockererbook.com/5/sinatra/webapp/

ls -l webapp/

chmod -x webapp/bin/webapp

sudo docker run -d p 4567 -v $PWD/webapp --name webapp wyb20161209/sinatra:1.0 

sudo docker logs webapp

sudo docker logs -f webapp

sudo docker port webapp 4567
