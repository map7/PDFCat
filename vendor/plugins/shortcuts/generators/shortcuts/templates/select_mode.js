/*
Author: Michael Pope
Desc:   
  Allows Highlighting of rows & execution of links on that row by ID
  Jumps focus to a set of commonly used predefined fields


Requirements:

Add to your template:
  <%= javascript_include_tag 'prototype', 'select_mode' %>

Must have a stylesheet loaded in your template which includes:
  .highlight { background: yellow } 

At the end of your template have:
  <script>setup('listing');</script>

Your table with rows must have a name which corresponds with what you put in your setup.  In this example it would be:
  <table id=listing>

Handy to have the following in your application.js
function hide_all(){
    clearHighlight();
    $('ajaxForm').hide();
}

This allows you to hide a div called ajaxForm and clear all the highlighted rows.


Any updated partials must include the following at the end of the partial:
<script>setupObserve();</script>



Examples:

<%= shortcut_function '0', "highlight(0);" %>
<%= shortcut_function '1', "highlight(1);" %>
<%= shortcut_function '2', "highlight(2);" %>
<%= shortcut_function '3', "highlight(3);" %>
<%= shortcut_function '4', "highlight(4);" %>
<%= shortcut_function '5', "highlight(5);" %>
<%= shortcut_function '6', "highlight(6);" %>
<%= shortcut_function '7', "highlight(7);" %>
<%= shortcut_function '8', "highlight(8);" %>
<%= shortcut_function '9', "highlight(9);" %>

<%= shortcut_function 's', "runSelected(0);" %>
<%= shortcut_function 'e', "runSelected(1);" %>
<%= shortcut_function 'd', "runSelected(2);" %>


 */

var rows;
var selRow;

var fields = [];      // Store all fields from the form into an array.
var jumps = [];  // Array of fields which you can bind a jump key.  Jump will allow you to quickly jump to common fields, unlike tab which will go through each.

var focusedElement = null;
var form = null;

// Setup variables to be used to hightlight and run row commands
function setup(listTable){
    // Detect if div exists and then fill out the variables
    if(document.getElementsByTagName && document.getElementById(listTable))
	rows = $(listTable).getElementsByTagName("tr"); 

}

// Highlight row
function highlight(row){
    selRow = row

    clearHighlight();

    for(i = 1; i < rows.length; i++){          
	if (row == i)
	    rows[row].className = "highlight";	
    }

}

// Clear all highlighting from a table.
function clearHighlight(){
    for(i = 1; i < rows.length; i++){          
	rows[i].className = "";
    }
}

// Run action on row
function runSelected(id){
    links = rows[selRow].getElementsByTagName("a");  // Get the links
    document.location = links[id];  // Go to the address.
}

// Run action on row (AJAX)
function runSelectedAjax(id){
    links = rows[selRow].getElementsByTagName("a");  // Get the links
    $(links[id]).onclick(); //For Ajax
}

// Run action on row by name.
// You have to define :method on your link eg:
// link_to 'Show', {:action => 'show', :id => category}, :id => "show", :method => :get
function runSelectedName(name){
    links = rows[selRow].getElementsByTagName("a");  // Get the links

    // Step through each link
    for(i=0;i<=links.length - 1;i++){

	// If the link matches the search criteria then click on it.
	if (links[i].id == name)
	    $(links[i]).onclick();
    }

}

// Run action on row (AJAX) by name.
function runSelectedAjaxName(name){
    links = rows[selRow].getElementsByTagName("a");  // Get the links

    // Step through each link
    for(i=0;i<=links.length - 1;i++){

	// If the link matches the search criteria then click on it.
	if (links[i].id == name)
	    $(links[i]).onclick();
    }

}





// Setup the jump fields.
function setupJumps(theForm, jumpFields){
    // Setup the global variable 'jump'
    form = theForm;
    jumps = jumpFields;

    // Get all the fields from the form and convert them from objects to id's.
    // Note:  Id's are better as they tend to be more stable on partial updates.
    theFields = $(form).getElements();
    for (i = 1; i < theFields.length; i++){    
	fields.push($(theFields[i]).id);
    }

    // Setup an observer on all fields to detect which is focused.
    setupObserve();

    // Select the first field
    $(jumps[0]).focus();
    $(jumps[0]).select();
}

// Setup a focus observer on all fields to detect which field is focused.
function setupObserve(){

    $$('input, select, textarea, checkbox').each(function(e){
	    e.observe('focus',function(e){
		    return function() { focusedElement = e; }
                }(e));
	    e.observe('blur',function(e){
		    return function() {
			if (focusedElement==e)
			    focusedElement = null;
		    }
                }(e));
        });
}

// Jump to the next field.  Bind this to a shortcut key.
function jumpNext(){
    jumpDone = false;

    // Get the current focused element.
    currentField = focusedElement;

    // Workout what number field the currently focused one is from the top. 'focusedElement'
    position = fields.indexOf(currentField.id);

    // Work out which field in the jump array would be next
    for (i = 0; i < jumps.length; i++){
	jump = fields.indexOf(jumps[i]);
	
	// select that field
	if (jump > position){
	    $(jumps[i]).focus();  // Jump to the next fiel
	    $(jumps[i]).select();
	    jumpDone = true;

	    break;        // Break out of the for loop
	}
    }
    
    // Jump to the first entry if no jump has been done.
    if (!jumpDone){
	$(jumps[0]).focus();
	$(jumps[0]).select();
    }
}

// Select the next field
function nextField(){

    // Get the current focused element.
    currentField = focusedElement;

    // Get current position within array of all input fields
    //    fields = $(form).getElements();

    position = fields.indexOf(currentField.id);

    // select the next field in the array
    if (position + 1 < fields.length){
	nField = fields[position + 1];
    }else{
	nField = fields[position];
    }

    // Focus & Select the next field
    $(nField).focus();
    $(nField).select();
}