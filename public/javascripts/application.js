// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


// Hide all
function hide_all(){
    $('info').hide();
    $('help').hide();

    clearHighlight(); // Clear highlighting from the last listing

    $('contentBox').focus();
}
