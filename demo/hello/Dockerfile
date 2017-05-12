FROM node:7.10.0

COPY ./ /usr/src
WORKDIR /usr/src

RUN npm install

EXPOSE 8080

CMD ["npm", "start"]