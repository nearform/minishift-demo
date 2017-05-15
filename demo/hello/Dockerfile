FROM node:6.10.3-alpine

RUN mkdir -p /usr/src/app/bin
RUN mkdir -p /usr/src/app/lib

COPY package.json /usr/src/app/lib
COPY ./ /usr/src/app/bin

WORKDIR /usr/src/app/lib

RUN npm install

WORKDIR /usr/src/app/bin

ENV NODE_PATH=/usr/src/app/lib/node_modules
ENV PATH=$PATH:/usr/src/app/lib/node_modules/.bin

CMD ["npm", "start"]