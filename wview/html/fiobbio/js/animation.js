/*jslint
  browser: false, node: true, devel: true, node: true */
/*global
  $ */
/* eslint-env jquery, browser */
/* eslint-disable no-alert, no-console */
"use strict";

$(function () {
  const nDivs = 6;
  var loadedDivs = 0;

  var elemList = [
    {name : "currweather", location : null},
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
            loadEleminNewDiv(e);
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

  function getDivId(slotNumber) {
      return "#slot" + slotNumber.toString();
  }

  function getUrl(elemName) {
    return "html/" + elemName + ".html";
  }


  function loadEleminNewDiv(elem) {
    if (loadedDivs <= nDivs) {
      var url = getUrl(elem.name);
      var divName = getDivId(loadedDivs++);

      console.log("Loading url=" + url + " into new div="+divName+"...");
      $(divName).load(url);
      elem.location = divName;
      return true;
    }

    return false;
  }

  function loadMore() {
    console.log("loadmore triggered...");

    elemList.some( function (e) {
      if (!e.location) {
        loadEleminNewDiv(e);
        $(window).bind('scroll', bindScroll);
        return (e.location !== null);
      }
      return false;
    });
  }

  $(window).scroll(bindScroll);

  function reloadCurrWeather () {
    console.log("Reloading current weather section...");
    var curr = elemList[0]
    $(curr.location).load(getUrl(curr.name));
    setTimeout(reloadCurrWeather, 150000);
  }


  $(document).ready(function() {
    loadedDivs = 0;
    loadEleminNewDiv(elemList[0]);
    setTimeout(reloadCurrWeather, 150000);
  });
});
