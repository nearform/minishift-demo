'use strict';

const mqtt = require('mqtt')
const restify = require('restify')

require('dotenv').config()

const pino = require('pino')({
	level: process.env.LOG_LEVEL || 'debug',
	name: 'Client'
});

const mqttBroker = `${process.env.MQTT_BROKER || 'mqtt://localhost'}`

pino.debug(`Connecting to MQTT broker ${mqttBroker}`)

const client  = mqtt.connect(mqttBroker)

client.on('connect', function () {
	pino.debug(`Connected...`);
	client.subscribe('ping')
})

client.on('message', function (topic, message) {
	pino.debug(message.toString());
})

const server = restify.createServer({
	name: 'Server'
})


server.get('/healthz', function (req, res, next) {
	res.json({
		status: 'OK',
		timestamp: new Date()
	})
	
	return next()
})

const port = process.env.SERVER_PORT || 3050

server.listen(port)