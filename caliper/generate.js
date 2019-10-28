'use strict';

const logger = require('@hyperledger/caliper-core').CaliperUtils.getLogger('txinfo');

let blockchain, context;
let clientIndex = 0;
let dataId = 0;

let sensorBatchSize = 1;
let totalClients = 0;

module.exports.info  = 'Caliper callback module for the fabcar benchmark';

module.exports.init = async (bc, contx, args) => {
    clientIndex = process.pid;
    dataId = clientIndex;
    totalClients = parseInt(args.clients.toString());
    sensorBatchSize = parseInt(args.sensor_batch_size.toString());

    blockchain = bc;
    context = contx;
};

function createSensorBatch() {
    let changes = [];
    for (let i = 0; i < sensorBatchSize; i++, dataId += totalClients) {
        changes.push({
            id: dataId,
            make: "Toyota",
            model: "Prius",
            color: "Silver",
            owner: "Bence"
        });
    }

    return sensors.map(s => JSON.stringify(s));
}

module.exports.run = async () => {
    let sensorData = createSensorBatch();
    let txArgs = {
        chaincodeFunction: 'createCar',
        chaincodeArguments: [''].concat(sensorData) // the first arg is the private collection name, empty means => don't use one
    };

    let results = await blockchain.invokeSmartContract(context, 'go', '', txArgs, 3);
    for (let result of results) {
        let txinfo = {
            tx_id: result.GetID(),
            time_create: result.GetTimeCreate(),
            time_end: result.GetTimeFinal(),
            status: result.GetStatus(),
            result: result.GetResult() ? result.GetResult().toString() : '',
        };

        let custom = result.GetCustomData();
        for (let entry of custom.entries()) {
            // convert CC return values to strings
            if (entry[0].includes('result')) {
                txinfo[entry[0]] = entry[1].toString();
            } else {
                txinfo[entry[0]] = entry[1];
            }
        }

        logger.info(JSON.stringify(txinfo));
    }
    return results;
};

module.exports.end = async () => {};