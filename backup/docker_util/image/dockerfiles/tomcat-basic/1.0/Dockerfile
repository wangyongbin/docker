FROM tomcat:8.5-jre8-alpine

RUN sed -i 's/8080/80/g;s/8443/443/g' $CATALINA_HOME/conf/server.xml 、
    && sed -i 's/${catalina.base}/\/app_vol/g' $CATALINA_HOME/conf/logging.properties 、
    && sed -i 's/"$CATALINA_BASE"\/logs\/catalina.out/\/app_vol\/logs\/catalina.out/g' $CATALINA_HOME/bin/catalina.sh \
    && sed -i 's/webapps/\/app_vol\/apps/g' $CATALINA_HOME/conf/server.xml

EXPOSE 80

CMD ["catalina.sh", "run"]