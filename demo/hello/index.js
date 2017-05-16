'use strict'

const restify = require('restify')
const level = require('level')

var db = level('./testdb')

const pino = require('pino')({
  level: process.env.LOG_LEVEL || 'debug',
  name: 'hello'
})

const server = restify.createServer({ name: 'hello' })

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
  db.put('time', t, function (err) {
    if (err) {
      res.status(500)
      res.json({msg: 'An error occurred'})
      return next(err)
    }
    res.json({msg: t})
    return next()
  })
})

server.listen(process.env.SERVER_PORT || 5000, function () { // bind server to port 5000.
  pino.info('%s listening at %s', server.name, server.url);
});
