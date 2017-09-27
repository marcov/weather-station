/*jslint
  browser: false, node: true, devel: true, node: true */
/*global
  doConfirm, phantom */
/* eslint-env node */
/* eslint-disable no-alert, no-console */
"use strict";
var system = require('system');


function getArgs() {
  var args = {
    url: "",
    waitTime: 5000,
    outFile: "website.png",
    viewSize: [1024, 800],
    cropSize: [0, 0, 1024, 800]
  };
  var tmp = [];

  if (system.args.length === 1 || system.args[1] === "-h" || system.args[1] === "--help") {
    console.log("Usage: phantomjs" + system.args[0] +
                " URL [waitTime] [outfile] [viewsize] [cropsize]");
    console.log("[viewsize]: WIDTHxHEIGHT");
    console.log("[cropsize]: TOPxLEFTxWIDTHxHEIGHT");
    phantom.exit();
  }
  
  args.url = system.args[1];
  
  if (system.args.length > 2) {
    args.waitTime = system.args[2];
  }
  
  if (system.args.length > 3) {
    args.outFile = system.args[3];
  }
  if (system.args.length > 4) {
    var viewSize = system.args[4].split("x");
    
    if (viewSize.length !== 2) {
      console.log("Invalid viewsize format");
      phantom.exit();
    }
    
    tmp = [];
    viewSize.forEach(function (i) {
      var n = parseInt(i);
      if (isNaN(n)) {
        console.log("Invalid viewsize format");
      }
      tmp.push(n);
      
    });
    args.viewSize = tmp;
  }
  
  if (system.args.length > 5) {
    var cropSize = system.args[5].split("x");
    if (cropSize.length !== 4) {
      console.log("Invalid cropsize format");
    }

    tmp = [];
    cropSize.forEach(function (i) {
      var n = parseInt(i);
      if (isNaN(n)) {
        console.log("Invalid viewsize format");
      }
      tmp.push(n);
      
    });
    args.cropSize = tmp;
  }
 
  console.log("args:\n" + JSON.stringify(args));

  return args;
}

function takeShot(page, outFile) {
  var evalResult = page.evaluate(function () {

    /* CML hack */
    try {
      return doConfirm(false);
    } catch (ReferenceError) {
      return "Nothing to eval";
    }
  });

  console.log(evalResult);
  
  page.render(outFile);
  console.log("Screenshot done");
  phantom.exit();
}

function main() {
  var page = require('webpage').create();
  var args = getArgs();


  //viewportSize being the actual size of the headless browser
  page.viewportSize = {width: args.viewSize[0],
                       height: args.viewSize[1]};
  //the clipRect is the portion of the page you are taking a screenshot of
  page.clipRect = {top: args.cropSize[0],
                   left: args.cropSize[1],
                   width: args.cropSize[2],
                   height: args.cropSize[3]};
 
  //console.log(JSON.stringify(page.viewportSize));
  //console.log(JSON.stringify(page.clipRect));
  
  page.onResourceRequested = function (request) {
    //console.log('Request ' + JSON.stringify(request, undefined, 4));
    console.log("+++ ask " + request.url);
  };
  page.onResourceReceived = function (response) {
    //console.log('Receive ' + JSON.stringify(response, undefined, 4));
    console.log("--- rx " + response.url);
  };

  page.onLoadFinished = function () {
    console.log("page Load Finished");
    setTimeout(takeShot, args.waitTime, page, args.outFile);
  };
  
  page.open(args.url, function (status) {
    
    if (status !== "success") {
      console.log(">>> page open FAILED!");
      phantom.exit();
    }
  });
}

main();
