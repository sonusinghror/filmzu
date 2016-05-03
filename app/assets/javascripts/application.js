// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery-1.9.0
//= require jquery_ujs
//= require jquery.poptrox.min
//= require jquery-migrate-1.2.1
//= require jquery.fancybox
//= require jquery.colorbox
//= require jquery.uniform
//= require twitter/bootstrap
//= require waypoints.min
//= require effects
//= require jquery-ui
//= require jquery-ui-slider-pips
//= require draggable-0.1
//= require jquery.dependClass-0.1
//= require jshashtable-2.1_src
//= require jquery.numberformatter-1.2.3
//= require tmpl
//= require respond.min
//= require caball
//= require prettify
//= require bootstrap-tagsinput
//= require social-likes.min
//= require jquery.geocomplete
//= require projects_proposal
//= require projects/numerous-2.1.1.js
//= require projects/slider.js
//= require application/sliding.form.js
//= require rails.validations
//= require_directory .
//= require init
//= require jquery.remotipart
//= require plugins/manifest.js
//= require social-share-button
//= require jquery-fileupload/basic
//= require html5shiv
//= require jquery.flexslider
//= require balanced
//= require balanced-1.1
//= require handlebars
//= require ember
//= require ember-data
//= require_self
//= require bootstrap-slider

//window.Caball = Ember.Application.create()

var lazy_featured_project = false;

$( document ).tooltip({
		hide: false,
		position: {
	        my: "center top+15",
	        at: "center bottom",
	        using: function( position, feedback ) {
	          $( this ).css( position );
	          $( "<div>" )
	            .addClass( "arrow" )
	            .addClass( feedback.vertical )
	            .addClass( feedback.horizontal )
	            .appendTo( this );
        }}});
jQuery(document).ready(function() {
  jQuery("abbr.timeago").timeago();
  jQuery(".timeago").timeago();
});
