'use strict';

const mqtt = require('mqtt')
const restify = require('restify')
const stringify = require('fast-safe-stringify')

require('dotenv').config()

const pino = require('pino')({
	level: process.env.LOG_LEVEL || 'debug',
	name: 'Server'
})

const mqttBroker = `${process.env.MQTT_BROKER || 'mqtt://localhost'}`

pino.debug(`Connecting to MQTT broker ${mqttBroker}`)

const client  = mqtt.connect(mqttBroker)

function ping(req, res, next) {
	pino.debug('sending message to MQTT:ping')
	
	const message = {
		code: 'pong',
		timestamp: new Date()
	}

	client.publish('ping', `${stringify(message)}`)

	res.json(message)
	
	return next()
}

function start() {
	pino.debug(`Connected to MQTT broker...`)
	const port = process.env.SERVER_PORT || 3050
	pino.debug(`Listen on ${port}`)
	server.listen(port)
}

const server = restify.createServer({
	name: 'Server'
})

server.get('/ping', ping)

server.get('/healthz', function (req, res, next) {
	res.json({
		status: 'OK',
		timestamp: new Date()
	})
	
	return next()
})

client.on('connect', start);
