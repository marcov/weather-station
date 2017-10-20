/*jslint
  browser: false, node: true, devel: true, node: true */
/*global
  $ */
/* eslint-env jquery */
/* eslint-disable no-alert, no-console */

(function () {
  'use strict';
  $('.hamburger-menu-wrapper').click(function (e) {
    e.preventDefault();
    if ($(this).hasClass('active')) {
      $(this).removeClass('active');
      $('.menu-overlay').fadeToggle('fast', 'linear');
      $('.menu .menu-list').slideToggle('slow', 'swing');
      $('.hamburger-menu-wrapper').toggleClass('bounce-effect');
    } else {
      $(this).addClass('active');
      $('.menu-overlay').fadeToggle('fast', 'linear');
      $('.menu .menu-list').slideToggle('slow', 'swing');
      $('.hamburger-menu-wrapper').toggleClass('bounce-effect');
    }
  });
})();