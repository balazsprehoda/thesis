'use strict';

const logger = require('@hyperledger/caliper-core').CaliperUtils.getLogger('txinfo');
const sys = require('sys')
//Allow valid Kubernetes names only.
const patternRegex = RegExp('[a-z0-9-.]*');
const actionRegex = RegExp('[a-z]*');
const exec = require('child_process').exec;

let blockchain, context, deployAfter, pumbaAction, targetPattern;
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
    if(args.targetPattern)
        targetPattern = args.targetPattern.toString();
    if(args.deployAfter)
        deployAfter = parseInt(args.deployAfter.toString());
    if(args.pumbaAction)
        pumbaAction = args.pumbaAction.toString();
    if(targetPattern && patternRegex.test(targetPattern)
        && pumbaAction && actionRegex.test(pumbaAction)
        && deployAfter) {
        exec("make pumba-generate TARGET_PATTERN=" + targetPattern + " ACTION=" + pumbaAction, {cwd: "/hyperledger/caliper/workspace"}, (err, stdout, stderr) => {
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
    else {
        logger.warn("Will not execute command, it contains illegal characters!");
    }
};

function deployPumba() {
    if(pumbaAction && actionRegex.test(pumbaAction
            && targetPattern && patternRegex.test(targetPattern))){
        exec("./kubectl create -f /hyperledger/caliper/workspace/network/pumba/pumba-" + pumbaAction + "-" + targetPattern + ".yaml", {cwd: "/hyperledger/caliper/workspace/kubectl"}, (err, stdout, stderr) => {
            if (err) {
                logger.warn("Could not execute Pumba deployment: " + err)
                return;
            }
            
            logger.info(`stdout: ${stdout}`);
            logger.warn(`stderr: ${stderr}`);
        });
    }
    else {
        logger.warn("Will not execute command, it contains illegal characters!");
    }
    
}

function randomInt(max) {
    return Math.floor(Math.random() * (max + 1));
}

function createChangeBatch() {
    let makeAndModel = makesAndModels[randomInt(makesAndModels.length - 1)];
    let id = "CAR" + randomInt(Number.MAX_SAFE_INTEGER - 1); //randomInt(max) calculates with max+1, so we need to pass MAX_VALUE-1... 
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