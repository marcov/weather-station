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
  var tmp = process.argv[1].split("/");
  var myname = tmp[tmp.length - 1];
  console.log("Usage:");
  console.log(myname + " <PHANTOMJS PATH> <phantomjs jsfile> config.json <DST PATH>");
}

function getArgs() {
  console.log("INFO: Getting command line arguments");

  var args = process.argv.slice(2);

  if (args.length < 4) {
    console.log("ERROR: not enough arguments provided");
    usage();
    process.exit();
  }

  if (args[0] === "-h" || args[0] === "--help") {
    usage();
    process.exit();
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
  console.log("INFO: webshot started");
  var allArgs = getArgs();

  var phantomJsExec = allArgs[0];
  var phantomJsFile = allArgs[1];
  var jsonCfg = allArgs[2];

  jsonCfg.websites.forEach( (ws) => {
    console.log("INFO: spawning phantomjs child process for "+ws.outFile);
    ws.outFile = jsonCfg.dstFolder + "/" + ws.outFile;
    child_process.spawnSync(phantomJsExec, [phantomJsFile, JSON.stringify(ws)], {stdio: 'inherit'});
  });

  console.log("INFO: done");
}

main();

