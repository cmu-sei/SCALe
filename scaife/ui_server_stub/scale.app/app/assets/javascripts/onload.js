// <legal>
// SCALe version r.6.7.0.0.A
// 
// Copyright 2021 Carnegie Mellon University.
// 
// NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING
// INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON
// UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR
// IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF
// FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS
// OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT
// MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT,
// TRADEMARK, OR COPYRIGHT INFRINGEMENT.
// 
// Released under a MIT (SEI)-style license, please see COPYRIGHT file or
// contact permission@sei.cmu.edu for full terms.
// 
// [DISTRIBUTION STATEMENT A] This material has been approved for public
// release and unlimited distribution.  Please see Copyright notice for
// non-US Government use and distribution.
// 
// DM19-1274
// </legal>

// This file defines the onload function, which will run on every page
window.onload = function() {
  // We hide any loaders
  $("#loader").hide();
  $("#project-loader").hide();

  //Upload Project to SCAIFE should trigger the loader
  $(".upload_project").click(function(){
	    //console.log("upload SCAIFE project click()");
	    $("#project-loader").show();
	  });

  // Ensure that these buttons trigger the loader
  $("#create_project_button").click(function(){
    $("#loader").show();
  });

  $("input[value='Filter']").click(function() {
    $("#loader").show();
  });

  $("#create_database_button, #edit_project_button").click(function(){
    if (validateProject()) {
      $("#loader").show();
      return true;
    } else {
      return false;
    }
  });

  $('#disconnect_from_scaife').bind('ajax:complete', function() {
    window.location.reload();
  });

  // toggle visibility of test suite elements
  $("#project_is_test_suite_true").click(function() {
    cb = $("#project_is_test_suite_true");
    $(".test-elements").each(function(index) {
      if (cb.is(':checked')) {
        $(this).show();
      }
      else if ($(this) !== cb) {
        $(this).hide();
      }
    });
  });

  $("#project_is_test_suite_false").click(function() {
    cb = $("#project_is_test_suite_false");
    $(".test-elements").each(function(index) {
      if (cb.is(':checked')) {
        $(this).hide();
      }
      else if ($(this) !== cb) {
        $(this).show();
      }
    });
  });

  // Click the filter button on load to start the loading of project
  // alertConditions
  $("input[value='Filter']").click();

}


$(document).ready(function(){

  // relies on hidden form field to be present
  var project_id = $('#project_id').attr('value');

/*Activating Best In Place */
jQuery(".best_in_place").best_in_place();

/*tooltips on hover*/
$('[data-toggle="tooltip"]').tooltip();

//for each element that is classed as 'pull-down', set its margin-top to the difference between its own height and the height of its parent
$('.pull-down').each(function() {
  var $this = $(this);
  $this.css('margin-top', $this.parent().height() - $this.height())
});

$(document).on('click', "#clear-filters", function(e){
	e.preventDefault();

	$.ajax({
	      type: "POST",
	      url: "/alertConditions/clearfilters",
	      datatype: "html",
	      success: function(result){
	        window.location.href = window.location.href.split('?')[0];
	      }
	});
});

/*Create drop-down action on hover*/
$('ul.nav li.dropdown, li.dropdown-submenu').hover(function() {
	  $(this).find('> .dropdown-menu').stop(true, true).delay(200).fadeIn(500);
	}, function() {
	  $(this).find('> .dropdown-menu').stop(true, true).delay(200).fadeOut(500);
});

/* Check the corresponding check box when a tool file output is uploaded */
$(document).on('change', '.file', function() {
  var upload = $(this).attr('name');
  var arr = /\[([^\]]+)\]/.exec(upload)
  if (arr !== undefined && arr.length > 0) {
    $('input[value="' + arr[1] + '"]').prop('checked', true);

    if(arr[1].startsWith("swamp")){
    	var dropdown_select = $("select[name$='"+ arr[1] +"\]']");
    	var dropdown_option = $("select[name$='"+ arr[1] +"\]']").find("option:selected").text().trim();

    	if(dropdown_option == "Choose Tool Information"){
    		$('#' + arr[1].replace('/', '-')).show();
    	}


    }
  }
});


  /* Update the tool version to match the actual tool for the swamp output */
  $(document).on('change', '.swamp_tool_select', function(){
    var selected = $(this).find("option:selected").text();
    var selected_split = selected.split("/");

    var selected_regex = /\[([^\]]+)\]/
    var tool_key = selected_regex.exec($(this).attr("name"));
    var thing = $("#tool_versions_" + tool_key[1].replace(/\//g, "\\/"));
    $("#tool_versions_" + tool_key[1].replace(/\//g, "\\/")).val(selected_split[2].trim());
    $('#' + tool_key[1].replace(/\//g, '-')).hide();
  });

  // Toggle the run classifier button based on the select dropdown options
  $(document).on("change", "#classifier_instance_chosen", function(){
	 classifier_text = $(this).val();

	 if (!classifier_text.trim()){ // The dropdown prompt has an empty string value.
		 $("#run-classifier-btn").prop('disabled', true);
	 }
	 else{
		 $("#run-classifier-btn").prop('disabled', false);
	 }
  });

  //get the chosen classifier and make request to run the classifier
  $(document).on('click', "#run-classifier-btn", function() {
   // classifier_instance_name = $("#classifierChosen").text();

    // Get the classifier seclected in the dropdown
    classifier_instance_name = $("#classifier_instance_chosen option:selected").text();

    var classify_button_text = $("#run-classifier-btn").html();

    $("#run-classifier-btn").html("Running...");

    $.ajax({
      type: "POST",
      url: "/alertConditions/" + project_id + "/classifier/run",
      data: {
        classifier_scheme_name: classifier_instance_name
      },
      datatype: "html",
      success: function(result){
    	$("#run-classifier-btn").html(classify_button_text);
        window.location.reload();
      }, error: function(xhr, status, err){
    	  $("#run-classifier-btn").html(classify_button_text);
    	  return false;
      }
    });
  });

  //end an experiment
  $(document).on('click', '#end-experiment-btn', function() {
      var end_experimet_button_text = $("end-experiment-btn").html();
      $("#end-experiment-btn").html("Exporting Data...");
      $.ajax({
          type: "POST",
          url: "/projects/" + project_id + "/end_experiment",
          datatype: "html",
          success: function(result){
              $("#end-experiment-btn").html(end_experimet_button_text);
              alert("Experiment has been successfully exported to $HOME/.exports!")
              window.location.reload();
          }, error: function(xhr, status, err){
              $("#end-experiment-btn").html(end_experimet_button_text);
              alert("Experiments failed to export.")
              return false;
          }
      });
  });

  // maintain language selection state between database view and
  // modal (also language upload to SCAIFE state)
  window.langselect_modal_state = {};

}); //end $(document).ready
