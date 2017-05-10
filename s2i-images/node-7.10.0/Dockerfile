FROM node:7.10.0

# This image provides a Node.JS environment you can use to run your Node.JS
# applications.
MAINTAINER nearform <salvatore.mazzarino@nearform.com>

# Add $HOME/node_modules/.bin to the $PATH, allowing user to make npm scripts
# available on the CLI without using npm's --global installation mode
# This image will be initialized with "npm run $NPM_RUN"
# See https://docs.npmjs.com/misc/scripts, and your repo's package.json
# file for possible values of NPM_RUN
ENV NODEJS_VERSION=7.10.0 \
    NPM_RUN=start \
    NPM_CONFIG_PREFIX=$HOME/.npm-global \
    PATH=$HOME/node_modules/.bin/:$HOME/.npm-global/bin/:$PATH \
    STI_SCRIPTS_PATH=/usr/local/s2i

LABEL summary="Platform for building and running Node.js 7.10.0 applications" \
      io.k8s.description="Platform for building and running Node.js 7.10.0 applications" \
      io.k8s.display-name="Node.js 7.10.0" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,nodejs,nodejs7" \
      io.openshift.s2i.scripts-url="image:///usr/local/s2i" \
      com.redhat.dev-mode="DEV_MODE:false" \
      com.redhat.deployments-dir="/home/app" \
      com.redhat.dev-mode.port="DEBUG_PORT:5858"

RUN useradd --user-group --create-home --shell /bin/false --uid 1001 app && \
  npm install --global npm@4.6.1

# Copy the S2I scripts from the specific language image to $STI_SCRIPTS_PATH
COPY ./s2i/bin/ $STI_SCRIPTS_PATH

# Each language image can have 'contrib' a directory with extra files needed to
# run and build the applications.
COPY ./contrib/ /home/app

# Drop the root user and make the content of /home/app owned by user 1001
RUN chown -R 1001:0 /home/app && chmod -R ug+rwx /home/app

WORKDIR /home/app
USER 1001

EXPOSE 8080

# Set the default CMD to print the usage of the language image
CMD [ "$STI_SCRIPTS_PATH/usage" ]
