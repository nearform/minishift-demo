'use strict'

const restify = require('restify')
const pino = require('pino')({
  level: process.env.LOG_LEVEL || 'debug',
  name: 'hello'
})

const server = restify.createServer({ name: 'hello' })

server.get('/', function (req, res, next) {

  res.json({ msg: 'Hello World' })
  return next()
})

server.get('/healthz', function (req, res, next) {
  res.json({ status: 'OK', timestamp: new Date() })
  return next()
})

server.get('/version', function (req, res, next){
  res.json({ version: '1.1' })
  return next()
})

server.get('/time', function(req, res, next) {
  var t = new Date()
  res.json({msg: t})
  return next()
})

server.listen(8080, '0.0.0.0', function () { // bind server to port 5000.
  pino.info('%s listening at %s', server.name, server.url);
});
