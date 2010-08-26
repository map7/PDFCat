// Capture all ajax requests
jQuery.ajaxSetup({ 
  'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
})

function rebind(){
    $(":input").overdrive({
	submit_after: true,
	field_nav: true,
	field_up: 38,
	field_down: 40,
	submit_key_code: 123});

    $('.help_btn').click(function(e){ $('div#help').toggle(); });
    
    $.focus_input();  // Set focus in form.
};

$(document).beeline({field_keys: ['esc','f1','f2', 'f3', 'f4', 'f5', 'f6', 'f7', 'f8', 'f9', 'f10']});
$(document).depechemode({container: "contentInner"} );

$(document).ready(function(event){
    rebind();
    
    // Ajax navigation
    $('a.ajax').live('click', function(e) { 
	e.preventDefault();
	link = $(this); 
	target = link.attr('target') === '' ? 'contentInner' : link.attr('target');

	switch (link.attr('id')){
	case "destroy": 
	    $.post(link.attr('href'), '_method=delete', null, 'script');
	    href = link.attr('return');
	    break;
	default:
	    href = link.attr('href');
	}

	$('#'+target).load(link.attr('href'), function() {
	    $('#'+target).ready(function(evt){ rebind(); });
	});
    });
});