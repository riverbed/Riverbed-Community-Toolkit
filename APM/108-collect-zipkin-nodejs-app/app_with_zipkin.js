// app_with_zipkin.js
//
// Aternity Tech-Community
// 108-collect-zipkin-nodejs-app
// version: 22.2.28
//
// Demo app in Nodejs with Zipkin instrumentation
//
// Refs:
//   * https://github.com/Aternity
//   * https://github.com/openzipkin
//
// Usage
//
// - Set environment variable
//   * ZIPKIN_SERVICE_NAME. For example: "service108-js"
//   * ZIPKIN_ENDPOINT. For example: http://localhost:9411/api/v2/spans or http://aternity-opentelemetry-collector:9411/api/v2/spans
//
// - Run the service
//
//   node app_with_zipkin.js
//
// - Test the service
//
//   curl http://localhost
//
//   curl http://localhost/fetch
//
//
// Example in PowerShell
//
//   $env:ZIPKIN_SERVICE_NAME="service108-js"
//   $env:ZIPKIN_ENDPOINT="http://aternity-opentelemetry-collector:9411/api/v2/spans"
//   node app_with_zipkin.js

'use strict';

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

// Initialize Zipkin instrumentation

const {
  Tracer,
  BatchRecorder,
  jsonEncoder: {JSON_V2}
} = require('zipkin');
const CLSContext = require('zipkin-context-cls');
const {HttpLogger} = require('zipkin-transport-http');

const tracer = new Tracer({
  ctxImpl: new CLSContext('zipkin'), // implicit in-process context
  recorder: new BatchRecorder({
    logger: new HttpLogger({
      endpoint: process.env.ZIPKIN_ENDPOINT || 'http://localhost:9411/api/v2/spans',
      jsonEncoder: JSON_V2
    })
  }),
  localServiceName: process.env.ZIPKIN_SERVICE_NAME || "service-js"
});

console.log("Zipkin tracing initialized");

// Instrument Express app adding a Zipkin middleware

const PORT = process.env.PORT || '80';
const express = require('express');
const app = express();

const zipkinMiddleware = require('zipkin-instrumentation-express').expressMiddleware;
app.use(zipkinMiddleware({tracer}));

// Instrument axios

const distAxios = require('axios');
const wrapAxios = require('zipkin-instrumentation-axiosjs');

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

// Service108 simple app

app.get('/fetch', (req, res) => {

    // add Zipkin wrapper
    const remoteServiceName = 'github'; 
    const axios = wrapAxios(distAxios, { tracer, remoteServiceName });

    var response = axios.get("https://github.com/Aternity")
    .then(function (response) {
    console.log("success");
    console.log(response);
    res.send('success');
    })
    .catch(function (error) {
    console.log("error");
    console.log(error);
    res.send('error');
    });
});

app.get('/', (req, res) => {
    res.send('ready');
});

app.listen(parseInt(PORT, 10), () => {
    console.log(`Listening for requests on http://localhost:${PORT}`);
});
