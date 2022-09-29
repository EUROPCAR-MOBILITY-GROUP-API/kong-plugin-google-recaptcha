'use strict';

const express = require('express');
const fs = require("fs");
const app = express();

app.set("port", process.env.PORT || 4000);

const dataPath = './data/users.json'

app.get('/api/v2/users', function (req, res) {
    fs.readFile(dataPath, 'utf8', (err, data) => {
        if (err) {
            console.log(err);
            throw err;
        }
        res.setHeader('content-type', 'application/json');
        res.status(200);
        res.send(JSON.parse(data));
        res.end();
    });
})

app.post('/api/v2/users', function (req, res) {
    res.setHeader('content-type', 'application/json');
    res.status(201);
    res.send({message: 'User is saved'});
    res.end();
})


const server = app.listen(app.get("port"), function () {

    const host = server.address().address;
    const port = server.address().port;
    console.log("Node.js API app listening at http://%s:%s", host, port)

});
