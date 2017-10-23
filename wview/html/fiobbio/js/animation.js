/*jslint
  browser: false, node: true, devel: true, node: true */
/*global
  $ */
/* eslint-env jquery, browser */
/* eslint-disable no-alert, no-console */
"use strict";

$("#link_top").click(function () {
  $('html,body').animate({scrollTop: $(".section_0").offset().top},
                         'slow');
});

$("#link_extrastas").click(function () {
  $('html,body').animate({scrollTop: $("#extrastas").offset().top},
                         'slow');
  $("#extrastas").empty();
  $("#extrastas").load("html/extrastas.html");
});

$("#link_forecast").click(function () {
  $('html,body').animate({scrollTop: $("#forecast").offset().top},
                         'slow');
  $("#forecast").empty();
  $("#forecast").load("html/forecast.html");
});

$("#link_radar").click(function () {
  $('html,body').animate({scrollTop: $("#radar").offset().top},
                         'slow');
  $("#radar").empty();
  $("#radar").load("html/radar.html");
});

$("#link_satellite").click(function () {
  $('html,body').animate({scrollTop: $("#satellite").offset().top},
                         'slow');
  $("#satellite").empty();
  $("#satellite").load("html/satellite.html");
});

$("#link_maps").click(function () {
  $('html,body').animate({scrollTop: $("#maps").offset().top},
                         'slow');
  $("#maps").empty();
  $("#maps").load("html/maps.html");
});

function bindScroll() {
  if ($(window).scrollTop() + $(window).height() > $(document).height() - 100) {
    $(window).unbind('scroll');
    loadMore();
  }
}

function loadMore() {
  console.log("More loaded");
  if ($("#extrastas").is(':empty')) {
    $("#extrastas").load("html/extrastas.html");
  } else if ($("#forecast").is(':empty')) {
    $("#forecast").load("html/forecast.html");
  } else if ($("#radar").is(':empty')) {
    $("#radar").load("html/radar.html");
  } else if ($("#satellite").is(':empty')) {
    $("#satellite").load("html/satellite.html");
  } else if ($("#maps").is(':empty')) {
    $("#maps").load("html/maps.html");
  }
  $(window).bind('scroll', bindScroll);
}

$(window).scroll(bindScroll);

function reloadCurrWeather () {
  console.log("Reloading current weather section...");
  $("#currweather").empty();
  $("#currweather").load( "currweather.htm" );
  setTimeout(reloadCurrWeather, 150000);
}

$(document).ready(function(){
  setTimeout(reloadCurrWeather, 0);
});

