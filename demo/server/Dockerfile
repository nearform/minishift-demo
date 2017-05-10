FROM node:7.10.0

RUN useradd --user-group --create-home --shell /bin/false --uid 1001 app

ENV HOME=/home/app

COPY package.json $HOME/

WORKDIR $HOME
USER 1001

RUN npm install

EXPOSE 8081

CMD ["npm", "start"]