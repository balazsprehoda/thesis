'use strict';

const logger = require('@hyperledger/caliper-core').CaliperUtils.getLogger('txinfo');

let blockchain, context;
let clientIndex = 0;
let dataId = 0;

let changeBatchSize = 1;
let totalClients = 0;

module.exports.info  = 'Caliper callback module for the fabcar benchmark';

module.exports.init = async (bc, contx, args) => {
    clientIndex = process.pid;
    dataId = clientIndex;
    totalClients = parseInt(args.clients.toString());

    blockchain = bc;
    context = contx;
};

function createChangeBatch() {
    let changes = [
        dataId.toString(),
        "Toyota",
        "Prius",
        "Silver",
        "Bence"
    ];

    return changes;
}

module.exports.run = async () => {
    let changeData = createChangeBatch();
    let txArgs = {
        chaincodeFunction: 'createCar',
        chaincodeArguments: changeData
    };

    let results = await blockchain.invokeSmartContract(context, 'go', '', txArgs, 10);
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