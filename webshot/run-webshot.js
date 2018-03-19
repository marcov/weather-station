/*jslint
  browser: false, node: true, devel: true, node: true */
/*global
/* eslint-env node */
/* eslint-disable no-alert, no-console */
"use strict";
var process = require('process');
const fs = require('fs');
const child_process = require('child_process');


function usage() {
    console.log("Usage: " + process.argv[0] + "<phantomjs executable> <phantomjs jsfile> cfg_file.json dst_path");
}

function getArgs() {

  console.log("getting argv...");

  var args = process.argv.slice(2);
  // console.log(args);

  if (process.argv.length === 0 || args[0] === "-h" || args[0] === "--help") {
    usage();
    phantom.exit();
  }

  var phantomJsExec  = args[0];
  var phantomJsFile  = args[1];
  var rawFileContent = fs.readFileSync(args[2]);
  var jsonCfg        = JSON.parse(rawFileContent);
  jsonCfg.dstFolder  = args[3];

  //console.log("jsonCfg:\n" + JSON.stringify(jsonCfg));

  return [phantomJsExec, phantomJsFile, jsonCfg];
}

function main() {
  console.log("starting up...");
  var allArgs = getArgs();

  var phantomJsExec = allArgs[0];
  var phantomJsFile = allArgs[1];
  var jsonCfg = allArgs[2];

  jsonCfg.websites.forEach( (ws) => {
    ws.outFile = jsonCfg.dstFolder + "/" + ws.outFile;
    child_process.spawnSync(phantomJsExec, [phantomJsFile, JSON.stringify(ws)], {stdio: 'inherit'});
    //console.log("CFG:");
    //console.log(JSON.stringify(ws));
  });
}

main();

