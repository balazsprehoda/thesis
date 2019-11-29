'use strict';

const logger = require('@hyperledger/caliper-core').CaliperUtils.getLogger('txinfo');
const sys = require('sys')
//Allow valid Kubernetes names only.
const regex = RegExp('[a-z0-9-.]*');
const exec = require('child_process').exec;

let blockchain, context, targetPattern;
let carId = 0;
let owners = [  
    "Bence", "Balazs", "Barni", "Blanka",
    "Marci", "Zoli", "Marcell", "Dani",
    "Gellert", "Agoston", "Julcsi", "Borka",
    "Levente", "Huba", "Hanga", "Soma"
];
let makesAndModels = [
    {make: "Toyota", model: "Prius"},
    {make: "Toyota", model: "Hiace"},
    {make: "Toyota", model: "Vitz"},
    {make: "Toyota", model: "Hilux"},
    {make: "Toyota", model: "Corolla"},
    {make: "Skoda", model: "Fabia"},
    {make: "Skoda", model: "Octavia"},
    {make: "Skoda", model: "Scala"},
    {make: "Skoda", model: "Kamiq"},
    {make: "Skoda", model: "Karoq"},
    {make: "Fiat", model: "Punto"},
    {make: "Fiat", model: "Panda"},
    {make: "Fiat", model: "Viaggio"},
    {make: "Fiat", model: "Ducato"},
    {make: "Fiat", model: "Cronos"},
    {make: "Ford", model: "Fiesta"},
    {make: "Ford", model: "Focus"},
    {make: "Ford", model: "Mustang"},
    {make: "Ford", model: "Explorer"},
    {make: "Ford", model: "Transit"},
    {make: "Tesla", model: "X"},
    {make: "Tesla", model: "3"},
    {make: "Tesla", model: "S"},
    {make: "Tesla", model: "Y"},
    {make: "Tesla", model: "Roadster"},
    {make: "Volkswagen", model: "Arteon"},
    {make: "Volkswagen", model: "Jetta"},
    {make: "Volkswagen", model: "Passat"},
    {make: "Volkswagen", model: "Golf"},
    {make: "Volkswagen", model: "Atlas"},
];

let colors = [
    "white", "black", "red", "yellow",
    "purple", "blue", "silver", "gold",
    "gray", "green", "brown", "orange"
];

module.exports.info  = 'Caliper callback module for the fabcar benchmark';

module.exports.init = async (bc, contx, args) => {
    blockchain = bc;
    context = contx;
    targetPattern = args.targetPattern.toString();
    var deployAfter = parseInt(args.deployAfter.toString());
    if(targetPattern && regex.test(targetPattern) && deployAfter) {
        // exec("rm ./pumba-*.yaml", {cwd: "/hyperledger/caliper/workspace/network/pumba"}, (err, stdout, stderr) => {
        //     if (err) {
        //       logger.warn("Could not clear directory: " + err);
        //       return;
        //     }
        //     logger.info(`stdout: ${stdout}`);
        //     logger.warn(`stderr: ${stderr}`);
        // });
        exec("make pumba-generate TARGET_PATTERN=" + targetPattern, {cwd: "/hyperledger/caliper/workspace"}, (err, stdout, stderr) => {
            if (err) {
              logger.warn("Could not execute Pumba configuration generation: " + err);
              return;
            }
          
            logger.info(`stdout: ${stdout}`);
            logger.warn(`stderr: ${stderr}`);
        });

        logger.info("Deploying pumba in " + deployAfter + " milliseconds");
        setTimeout(deployPumba, deployAfter);
    }
    
};

function deployPumba() {
    exec("./kubectl create -f /hyperledger/caliper/workspace/network/pumba/*.yaml", {cwd: "/hyperledger/caliper/workspace/kubectl"}, (err, stdout, stderr) => {
        if (err) {
          logger.warn("Could not execute Pumba deployment: " + err)
          return;
        }
      
        logger.info(`stdout: ${stdout}`);
        logger.warn(`stderr: ${stderr}`);
    });
}

function randomInt(max) {
    return Math.floor(Math.random() * (max + 1));
}

function createChangeBatch() {
    let makeAndModel = makesAndModels[randomInt(makesAndModels.length - 1)];
    let id = "CAR" + carId.toString();
    let make = makeAndModel.make;
    let model = makeAndModel.model;
    let color = colors[randomInt(colors.length - 1)];
    let owner = owners[randomInt(owners.length - 1)];
    let changes = [
        id,
        make,
        model,
        color,
        owner
    ];
    carId += 1;

    return changes;
}

module.exports.run = async () => {
    let changeData = createChangeBatch();
    let txArgs = {
        chaincodeFunction: 'createCar',
        chaincodeArguments: changeData
    };

    let results = await blockchain.invokeSmartContract(context, 'go', '', txArgs, 20);
    return results;
};

module.exports.end = async () => {};