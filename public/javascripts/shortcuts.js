/*

shortcuts.js
Version: 1.00

This script allows you to use shortcut keys to control web applications.

Modified By: Michael Pope

TODO
- decouple relationship between this file and the required divs 'info', 'mode' and 'modeKeys'
- clean up the code
- push changes to the repository for this plugin (shortcuts)
- Reduce the number of requirements for use.

Current Requirements
- Your listing should be surrounded by a div with id 'listing'
- You should have divs with id 'info', 'mode' and 'modeKeys'
- Your links Show, Edit & Destroy should be in that order.


*/



// Setup any global variables
var fkeyselect = false;//select mode.
var fkey=0;//store the function key last pushed.

if (!window.Shortcuts) {
  var Shortcuts = new Object();
}

Object.extend(Shortcuts, {

	shortcuts:false,

	register_shortcut: function( key, handler ) {
		if (!this.shortcuts)
		    this.shortcuts=[];

		this.shortcuts[key] = handler;
	},
	
	// Used to jump to important windows within the application using the Ctrl + <char>
        register_shortcut_ctrl: function( key, handler ) {
		if (!this.shortcut_ctrls)
		    this.shortcut_ctrls=[];

		this.shortcut_ctrls[key] = handler;
	},
	
	go:function(key) {
		handler = Shortcuts.shortcuts[character];
		if (handler) {
		    alert(key);
		    handler(key);
		}
	},
	
	start: function() {
		Event.observe(document, 'keypress', function(e){

				var target;
				if (!e) var e = window.event;
				if (e.target) target = e.target;
				else if (e.srcElement) target = e.srcElement;
				if (target.nodeType == 3) // defeat Safari bug
					target = target.parentNode;


				// For ctrl shortcuts Ctrl + <code>
				if (e.ctrlKey){

				    if (e.keyCode) code = e.keyCode;
				    else if (e.which) code = e.which;

				    var character = String.fromCharCode(code).toLowerCase();
				    //alert(character)
		
				    handler = Shortcuts.shortcut_ctrls[character];

				    if (handler) {
					Event.stop(e);
					handler(character);
				    }


				}


				// Fill the variables
				if(document.getElementsByTagName && document.getElementById("listing")){
				    // Get the objects
				    var thediv = document.getElementById("listing");  
				    var tables = thediv.getElementsByTagName("table");  
				    var rows = tables[0].getElementsByTagName("tr"); 

				    // Get paginate object
				    //var paginatelinks = document.getElementById("paginate").getElementsByTagName("a");
				    //alert(paginatelinks[paginatelinks.length-1]);
				}




				// Select Mode.
				// This is where we have special functions for items such as show, edit, destroy.
				if(e.keyCode != 27 && fkeyselect && (e.keyCode < 112 || e.keyCode > 121)){


				    //alert("select function");

				    e.preventDefault();  // Stop the default

				    // Get the key
				    var character = String.fromCharCode(e.which).toLowerCase();


				    // Step through the table again
				    if(document.getElementsByTagName){  // Check that we have the functionality

					// Select the row
					for(i = 1; i < rows.length; i++){          
					    //manipulate rows
					    if(i == fkey){
						//alert(rows[i].contents);
						rows[i].className = "highlight";

						var links = rows[i].getElementsByTagName("a");
						
						//alert(links[0])
						
						// Find out the function (show,edit,destroy) and click the relevant button.
						if(character == "s" || character == "/")
						    $(links[0]).onclick();
						else if(character == "e" || character == "*")
						    $(links[1]).onclick();
						else if(character == "d" || character == "-")
						    $(links[2]).onclick();
						else if(character == "t")
						    $(links[3]).onclick();


					    }else{
						rows[i].className = "clear";
					    }      
					}
				    }


				    // Reset and exit
				    $('info').hide();
				    $('modeKeys').hide();

				    fkey=0;
				    fkeyselect=false;

				    return;
				}else{

				    // Check that we have the functionality
				    if(document.getElementsByTagName && document.getElementById("listing")){
					// Select the row
					for(i = 1; i < rows.length; i++){          
					    rows[i].className = "clear";
					}
				    }
				}

				// ENTER Select Mode & Highlight item.
				// Check that you are not in a form element and that the user has hit F1 -> F10
				if (e.keyCode >= 112 && e.keyCode <= 121 && target.tagName.toLowerCase()!='input' && target.tagName.toLowerCase()!='textarea' && target.tagName.toLowerCase()!='select' ) {


				    // display select mode.
				    $('info').show();
				    $('modeKeys').show();
				    $('mode').innerHTML="Select Mode";
				    $('modeKeys').innerHTML="" +
					"<table>" +
					"<th>Function</th>  <th> key  </th>" +
					"<tr><td>Show</td>  <td>s or /</td></tr>" +
					"<tr><td>Edit</td>  <td>e or *</td></tr>" +
					"<tr><td>Delete</td><td>d or -</td></tr>" +
					"</table>";

				    fkeyselect=true;     // Set the global toggle for the select mode.
				    e.preventDefault();  // Stop the default
					    
				    // select the item.
				    fkey = e.keyCode - 111;
				    //alert ("function key " + (fkey+1)  + " hit");

				    // Check that we have the functionality
				    if(document.getElementsByTagName){

					// Select the row
					for(i = 1; i < rows.length; i++){          
					    //manipulate rows
					    if(i == fkey){
						rows[i].className = "highlight";
					    }else{
						rows[i].className = "clear";
					    }      
					}
				    }



				    return;
				} // List selection




				// Remember to skip the shortcut keys on form elements unless it's ESC (ASCII=27)
				// Or F11 (Accept form)
				if (e.keyCode == 27 || e.keyCode >= 112 && e.keyCode <= 123 || target.tagName.toLowerCase()!='input' && target.tagName.toLowerCase()!='textarea' && target.tagName.toLowerCase()!='select') {
				    var code;


				    $('info').hide();
				    $('modeKeys').hide();
				    fkeyselect = false;
				    fkey=0;


				    //alert("main function");
				    //alert(e.keyCode);
				    //alert(e.ctrlKey);
				    //alert(e.which);

				    if (e.keyCode) code = e.keyCode;
				    else if (e.which) code = e.which;

				    // Function keys go through keyCode, whilst characters go through which.
				    // EG: code=122 is F11 & z, but only keyCode = 122 is F11 and which = 122 is z.
					
				    //Stop the default actions for:
				    //  Function keys 112 -> 123
				    if (code >= 112 && code <= 123 && !e.ctrlKey && !e.altKey && !e.metaKey)
					e.preventDefault();  // Stop the default

				    //alert(code);
					
				    // ignore modifiers that trigger accesskey links
				    if (e.ctrlKey || e.altKey || e.altGraphKey || e.metaKey)
					return;
					
				    var character = String.fromCharCode(code).toLowerCase();
				    //alert(character)
		
				    handler = Shortcuts.shortcuts[character];
				    if (handler) {
					Event.stop(e);
					handler(character);
				    }
				}
				
		 	},
		 	false
		);
	}
	
});
Shortcuts.start();
