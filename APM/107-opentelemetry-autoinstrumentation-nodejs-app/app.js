// app.js
//
// Aternity Tech-Community
// 107-opentelemetry-autoinstrumentation-nodejs-app
// version: 22.4.1
//
// Demo app in Nodejs
//
// Usage
//
//  - run the service
//
//   node app.js
//
// - test from a client
//
//   curl http://localhost
//
//   curl http://localhost/fetch

'use strict';

const PORT = process.env.PORT || '80';
const express = require('express');
const axios = require('axios');

const app = express();

app.get('/fetch', (req, res) => {
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
