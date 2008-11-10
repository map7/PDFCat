// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
//
// Author: Michael Pope
// Version: 1.00


// Hiding Forms
function hide_form(){
    // Focus on the content div
    $('content').focus(); 

    // Hide the ajaxForm
    $('ajaxForm').hide();
}


// Hide all
function hide_all(){

    hide_form();

    $('keys').hide(); 
    $('help').hide();

    // Clear the data in a form if it exists.
    if ($('form')){ $('form').reset(); }
}

function clear_form(){
    if ($('form')){ $('form').reset(); }
}

