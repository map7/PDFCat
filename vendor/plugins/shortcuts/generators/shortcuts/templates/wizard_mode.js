/*
Author: Michael Pope
Desc:   
  When a user enters a form wizard these buttons come into play.
  Mainly this allows you to step next and previous in a wizard.

  The main problem with next & previous shortcuts is that in your wizard
  you are going to have many buttons called 'next'.  So we have to keep 
  track of where the user is up to and which next button is the correct
  one to link to.

Requirements:
  Add the following to your template
  <%= javascript_include_tag 'wizard_mode' %>

  Your next & prev page links are links not buttons and have an id of next and prev

*/

var page;  // store which page of the wizard you are up to.
var nextBtns=new Array();
var prevBtns=new Array();

function setupForm(formName){
    // Detect if div exists and then fill out the variables
    if(document.getElementsByTagName && document.getElementById(formName))
	buttons = $(formName).getElementsByTagName("a");     
    
    page = 0;

    // Go through each of the buttons and split them up.
    for(i=0;i<=buttons.length -1; i++){
	if (buttons[i].id == 'next')
	    nextBtns.push(buttons[i]);

	if (buttons[i].id == 'prev')
	    prevBtns.push(buttons[i]);

    }

}

function nextPage(){
    // Go to the next page.
    if (page < nextBtns.length){
	nextBtns[page].onclick();
	page = page + 1;
    }
}

function prevPage(){
    // Go to the prev page.
    if (page > 0){
	prevBtns[page - 1].onclick();
	page = page - 1;
    }
}


