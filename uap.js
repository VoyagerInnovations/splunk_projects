//Author: Maynard Louis E. Prepotente
//Date: October 22, 2019

require(['jquery','underscore','splunkjs/mvc', 'bootstrap.tab', 'splunkjs/mvc/simplexml/ready!'],
		function($, _, mvc){
	
	/**
	 * The below defines the tab handling logic.
	 */
	
	// The normal, auto-magical Bootstrap tab processing doesn't work for us since it requires a particular
	// layout of HTML that we cannot use without converting the view entirely to simpleXML. So, we are
	// going to handle it ourselves.
	var hideTabTargets = function(){
		
		var tabs = $('a[data-elements]');
		
		// Go through each toggle tab
		for(var c = 0; c < tabs.length; c++){
			
			// Hide the targets associated with the tab
			var targets = $(tabs[c]).data("elements").split(",");
			
			for(var d = 0; d < targets.length; d++){
				$('#' + targets[d], this.$el).hide();
			}
		}
	};
	
	var selectTab = function (e) {
		
		// Stop if the tabs have no elements
		if( $(e.target).data("elements") === undefined ){
			console.warn("Yikes, the clicked tab has no elements to hide!");
			return;
		}
		
		// Get the IDs that we should enable for this tab
		var toToggle = $(e.target).data("elements").split(",");
		
		// Hide the tab content by default
		hideTabTargets();
		
		// Now show this tabs toggle elements
		for(var c = 0; c < toToggle.length; c++){
			$('#' + toToggle[c], this.$el).show();
		}
		
	};
	
	// Wire up the function to show the appropriate tab
	$('a[data-toggle="tab"]').on('shown', selectTab);
	
	// Show the first tab
	$('.toggle-tab').first().trigger('shown');
	
	// Make the tabs into tabs
    $('#tabs', this.$el).tab();
    
    /**
     * The code below handles the tokens that trigger when searches are kicked off for a tab.
     */
    
    // Get the tab token for a given tab name
    var getTabTokenForTabName = function(tab_name){
    	return tab_name; //"tab_" + 
    }
    
    // Get all of the possible tab control tokens
    var getTabTokens = function(){
    	var tabTokens = [];
    	
    	var tabLinks = $('#tabs > li > a');
    	
    	for(var c = 0; c < tabLinks.length; c++){
    		tabTokens.push( getTabTokenForTabName( $(tabLinks[c]).data('token') ) );
    	}
    	
    	return tabTokens;
    }
    
    // Clear all but the active tab control tokens
    var clearTabControlTokens = function(){
    	console.info("Clearing tab control tokens");
    	
    	var tabTokens = getTabTokens();
    	var activeTabToken = getActiveTabToken();
    	var tokens = mvc.Components.getInstance("submitted");
    	
    	// Clear the tokens for all tabs except for the active one
    	for(var c = 0; c < tabTokens.length; c++){
    		
    		if( activeTabToken !== tabTokens[c] ){
    			tokens.set(tabTokens[c], undefined);
    		}
    	}
    }
    
    // Get the tab control token for the active tab
    var getActiveTabToken = function(){
    	return $('#tabs > li.active > a').data('token');
    }
    
    // Set the token for the active tab
    var setActiveTabToken = function(){
    	var activeTabToken = getActiveTabToken();
    	
    	var tokens = mvc.Components.getInstance("submitted");
    	
    	tokens.set(activeTabToken, '');
    }
    
    var setTokenForTab = function(e){
    	
		// Get the token for the tab
    	var tabToken = getTabTokenForTabName($(e.target).data('token'));
		
		// Set the token
		var tokens = mvc.Components.getInstance("submitted");
		tokens.set(tabToken, '');
		
		console.info("Set the token for the active tab (" + tabToken + ")");
    }
    
    $('a[data-toggle="tab"]').on('shown', setTokenForTab);
    
    // Wire up the tab control tokenization
    var submit = mvc.Components.get("submit");
    
    submit.on("submit", function() {
    	clearTabControlTokens();
    });
    
    // Set the token for the selected tab
    setActiveTabToken();
    
});

//Get current user
require([ 'underscore', 'jquery', 'splunkjs/mvc', ],
       function(_, $, mvc ) {        
          var tokens = mvc.Components.getInstance("default");       
          var current=Splunk.util.getConfigValue("USERNAME");        
          tokens.set("currentUser", current);
});

//Get action based on tab selected
require(['jquery','underscore','splunkjs/mvc', 'bootstrap.tab', 'splunkjs/mvc/simplexml/ready!'],
		function($, _, mvc){
	
    	var getActvTabToken = function(){
    		return $('#tabs > li.active > a').data('token');
    	}
		
    	var setActvTabToken = function(){
    		var actvTabToken = getActvTabToken();
    	
    		var tokens = mvc.Components.getInstance("submitted");
    	
    		tokens.set("myToken",actvTabToken);
    	}

	$('a[data-toggle="tab"]').on('shown', setActvTabToken);

	var getActvTabToken2 = function(){
                return $('#tabs2 > li.active > a').data('token');
        }

        var setActvTabToken2 = function(){
                var actvTabToken2 = getActvTabToken2();

                var tokens2 = mvc.Components.getInstance("submitted");

                tokens2.set("myToken2",actvTabToken2);
        }

        $('a[data-toggle="tab"]').on('shown', setActvTabToken2);


});

//Confirmation before submit
require([
    "splunkjs/mvc",
    "jquery",
    "splunkjs/mvc/searchmanager",
    "splunkjs/mvc/simplexml/ready!"
  ], function(
      mvc,
      $,
      SearchManager
  ) {
     	function executeUpdate(){ 
		var tokens = mvc.Components.getInstance("default");
	        var current=Splunk.util.getConfigValue("USERNAME");
      		tokens.set("currentUser", current);

	        var mysearch = new SearchManager({
                id: "mysearch2+epoch",
	        autostart: "false",
		cache: 'false',
	 	search: "| updateprofile " + current
      		});
     	 	
		mysearch.startSearch();
	
		 mysearch.on('search:failed', function(properties) {
        	 // Print the entire properties object
         	console.log("FAILED:", properties);
		 alert("Failed, please try again.");
     		 });
    	 	mysearch.on('search:progress', function(properties) {
        	 // Print just the event count from the search job
         	console.log("IN PROGRESS.\nEvents so far:", properties.content.eventCount);
     		});
     		mysearch.on('search:done', function(properties) {
         	// Print the search job properties
         	console.log("DONE!\nSearch job properties:", properties.content);            
     		});		
	
		setTimeout(function(){
			mvc.Components.getInstance('input_file').val('')
			mvc.Components.getInstance('input_jira').val('')
			mvc.Components.getInstance('input_min').val('')
			mvc.Components.getInstance('input_lname').val('')
			mvc.Components.getInstance('input_fname').val('')
			mvc.Components.getInstance('input_oldMin').val('')
			mvc.Components.getInstance('input_newMin').val('')
			mvc.Components.getInstance('input_srcMin').val('')
			mvc.Components.getInstance('input_RRN').val('')
			mvc.Components.getInstance('input_ufn').val('')
			mvc.Components.getInstance('input_umn').val('')
			mvc.Components.getInstance('input_uln').val('')
			mvc.Components.getInstance('input_uan').val('')
			mvc.Components.getInstance('input_uav').val('')
			mvc.Components.getInstance('input_uat').val('')
			mvc.Components.getInstance('input_ub').val('')
			mvc.Components.getInstance('input_uea').val('')
			mvc.Components.getInstance('input_kyc').val('')
			}, 3000);
	}
	
        function validateMin(min){
                var minPatt = /^\+\d{12}$/;
                var check = minPatt.exec(min);
                if(!check){
                alert(min + " is invalid MIN format");
                throw new Error("Invalid MIN");
		}
        }

	function minEmpty(minVal) {
                if (minVal == null || minVal === "" ) {
                } else { validateMin(minVal); }
        }

	function validateForm(){
                var token = mvc.Components.get("default");
                var caseNum = token.get("tkn_jira");
		var min = token.get("tkn_min");
		var oldMin = token.get("tkn_oldMin");
		var newMin = token.get("tkn_newMin");
		var srcMin = token.get("tkn_srcMin");
		
		minEmpty(min);minEmpty(oldMin);minEmpty(newMin);minEmpty(srcMin);	
		if ( caseNum == null || caseNum === "" ){
                	alert("Case number empty. Please fill up field with unique case number.");
                	return;
                }else {
			var ok = confirm("Do you wish to confirm?");
                	if ( ok==true ){
			 	executeUpdate();} else { return; }
        		}
	}

	$('.btn-primary').on("click", function (){
                validateForm();
	});
 });

