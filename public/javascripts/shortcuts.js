/*
shortcuts.js
Desc:   
  Allows you to bind functions to shortcut keys.

Requirements:

If you want to override the behaviour of the 'Enter' key then add this to the application.html.erb
  <script>overrideEnter();</script>

Note if you have 'hidden' fields and you want to override the Enter key then you must have these hidden fields as the first fields in your form.

 */

var changeEnter = false;

function overrideEnter(){
    changeEnter = true;
}

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
	
	// Control key + shortcut.
        register_shortcut_ctrl: function( key, handler ) {
		if (!this.shortcut_ctrls)
		    this.shortcut_ctrls=[];

		this.shortcut_ctrls[key] = handler;
	},

	// Function keys (Key should equal the function key number, EG: F4 would be '4')
        register_shortcut_fnkey: function( key, handler ) {
		if (!this.shortcut_fnkeys)
		    this.shortcut_fnkeys=[];

		this.shortcut_fnkeys[key] = handler;
	},

	go:function(key) {
		handler = Shortcuts.shortcuts[character];
		if (handler) {
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

				// Function Keys
				if (e.keyCode >= 112 && e.keyCode <= 123){


				    fnKey= e.keyCode - 111   // Calculate which Function Key number was pressed.
		
				    // Call the handler for the function key.
				    handler = Shortcuts.shortcut_fnkeys[fnKey];

				    if (handler) {
					e.preventDefault();      // Stop the browser function, if user you override with a different function.
					Event.stop(e);
					handler(character);
				    }

				    return;
				}

				// For ctrl shortcuts Ctrl + <character>
				if (e.ctrlKey){

				    if (e.keyCode) code = e.keyCode;
				    else if (e.which) code = e.which;

				    // Get the character attached to the Ctrl sequence and turn that into lowercase
				    var character = String.fromCharCode(code).toLowerCase();
		
				    // Call the handler for the ctrl
				    handler = Shortcuts.shortcut_ctrls[character];

				    if (handler) {
					Event.stop(e);
					handler(character);
				    }
				}

				

				if (changeEnter && e.keyCode == 13 && target.type.toLowerCase()!='submit' || e.keyCode == 27 || target.tagName.toLowerCase()!='input' && target.tagName.toLowerCase()!='textarea'  && target.tagName.toLowerCase()!='select') {
					var code;
					if (e.keyCode) code = e.keyCode;
					else if (e.which) code = e.which;
					
					// ignore modifiers that trigger accesskey links
					if (e.ctrlKey || e.altKey || e.altGraphKey || e.metaKey)
						return;
					
					var character = String.fromCharCode(code).toLowerCase();
		
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
