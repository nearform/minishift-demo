# Keycloak

## Install keycloak

Postgress installed and create db ( for testing)


rons-MacBook-Pro:bin ronlitzenberger$ pwd
/Library/PostgreSQL/9.6/bin

./createdb -U postgres mytest


To start the server open the directory you extracted Keycloak into and run
keycloak-1.6.0.Final/bin/standalone.sh

In standalone mode you can have it running without setting up the database and configuration.  But this will only be for local development

You should now have the Keycloak server up and running. To check that it's working openhttp://localhost:8080/auth. Then click on Admin Console the username is admin and password is admin. You'll be asked to change the default password when you login.