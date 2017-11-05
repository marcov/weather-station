/*jslint
  browser: false, node: true, devel: true, node: true */
/*global
  $ */
/* eslint-env jquery, browser */
/* eslint-disable no-alert, no-console */
"use strict";


var nDivs = 6;
var elemList = [
  {name : "currweather", location : "#slot0"},
  {name : "extrastas",   location : null},
  {name : "forecast",    location : null},
  {name : "radar",       location : null},
  {name : "satellite",   location : null},
  {name : "maps",        location : null}
];

var canLoadMore = true;

document.addEventListener('click', function (e) {
  var target = e.target;
  if (target.tagName && target.tagName.toLowerCase() === "a") {
    console.log("clicked " + target.id);
    
    elemList.some(function (e) {
      if ("link_" + e.name == target.id) {
        var url = "html/" + e.name + ".html";
       
        canLoadMore = false;
        console.log("is a known element!");
        if (e.location === null) {
          e.location = loadNewDiv(url); 
        }
        else {
          console.log("element already loaded...");
        }
        
        $('html,body').animate({scrollTop: $(e.location).offset().top},
                               'slow');
        
        canLoadMore = true;
        return true;
      }
      return false;
    });
  }
});

function bindScroll() {
  if ($(window).scrollTop() + $(window).height() > $(document).height() - 100) {
    if (canLoadMore) {
      $(window).unbind('scroll');
      loadMore();
    }
  }
}

function loadNewDiv(url) {
  console.log("Loading new div for url " + url + "...");
      
  for (var i = 0; i < nDivs; i++) {
    var divName = "#slot" + i.toString();
    console.log("trying " + divName);
  
    if ($(divName).is(':empty')) {  
      console.log("is empty!");
      $(divName).load(url);
      return divName;
    }
  }
  
  return null;
}

function loadMore() {
  console.log("loadmore triggered...");
  
  elemList.some( function (e) {
    if (!e.location) {
      var url = "html/" + e.name + ".html";
      e.location = loadNewDiv(url); 
      $(window).bind('scroll', bindScroll);
      return (e.location !== null);
    }    
    return false;
  });
}

$(window).scroll(bindScroll);

function reloadCurrWeather () {
  console.log("Reloading current weather section...");
  loadNewDiv("currweather.htm");
  setTimeout(reloadCurrWeather, 150000);
}

$(document).ready(function(){
  setTimeout(reloadCurrWeather, 0);
});

