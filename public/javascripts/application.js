// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// Capture all ajax requests
jQuery.ajaxSetup({ 
  'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
})

$(document).beeline();
$(document).depechemode({container: "contentInner"} );

$(document).ready(function(event){
    // Ajax navigation
    $('a.ajax').live('click', function(e) { 
	e.preventDefault();
	link = $(this); 
	target = link.attr('target') === '' ? 'contentInner' : link.attr('target');
	$('#'+target).load(link.attr('href'), function() {});
    });
});


/*
// Hide all
function hide_all(){
    $('info').hide();
    $('help').hide();

    clearHighlight(); // Clear highlighting from the last listing

    $('contentBox').focus();
}
*/