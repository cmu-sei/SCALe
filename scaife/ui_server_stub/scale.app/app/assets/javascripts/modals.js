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

$(document).ready(function(){

	//Update the contents of the placement modal based on the link selected.
	$('.classifiers').click(function(e){
		var thisClassName = $(this).attr('class');
		var thisProject = $('#project_id').attr('value'); //get current project value (NOTE: These links are in the header; the controller has no access to the current project id)
		var taxonomyList = null;
		var chosenLink = $(this).text();
		var error_msg = ""

		switch(thisClassName){ //create the appropriate text for the submit button in modal
		//if classifier is an existing than call edit if not call open

		case 'classifiers existing-classifier':
			openEditModal(chosenLink);
			return;

		case 'classifiers':
			$('#submit-modal').html("Create Classifier");
			$('#label-modal').attr('title', "Upload data to train the classifier");
			break;

		case 'classifiers existing-classifier':
			openEditModal(chosenLink);
			return;
		}

		//GET request to render modal body
		$.ajax({
			type: "GET",
			url: '/modals/open',
			data: {
				className: thisClassName,
				project_id: thisProject,
				chosen: chosenLink,
				taxonomy: taxonomyList
			},
			datatype: "html",
			success: function(result){
				$('#modal-body').html(result);
	            var modal_title = $('#label-modal').text();
	            if ("" === modal_title){
	                error_msg = "Failed to connect to SCAIFE servers"
	                $('#classifier-errors').html(error_msg);
	                $('#classifier-errors').show();
	            }
			},
			error: function(error){
				error_message = 'Projects must be uploaded to SCAIFE first';
				if (error.responseText.includes(error_message))
					alert("ERROR: " + error_message);
				else
					alert("ERROR: Undefined Error. Closing popup window! "); //limit the response given to user for security
			    $('#modal-placement').modal('toggle'); //close modal window when failed to get it's body
			    return false;
			}
		});
	});

	//remove header and body contents of the placement modal on close
	$('#modal-placement').on('hidden.bs.modal', function(){
		$('#modal-body').html("");
		$('#label-modal').html("");
                $('#classifier_id').html("");
	});

	//render the body of the alertConditions modal
	$('#myModal, #modal-placement').on('show.bs.modal', function(e){
		$.ajax({
			cache: false,
			type: 'GET',
			url: $(e.relatedTarget).attr('href'),
		});
	});

	//remove cached data from modal when it is closed
	$('.modal').on('hide.bs.modal', function(e){
		$(this).remove('bs.modal');
	});

	//Perform Data Validation of Modal Forms prior to submitting
    $(document).on('click', '#submit-modal', function(e){
    	e.preventDefault();

    	var classifier_id = $('#classifier_id').text();
    	var classifier_type = $('#label-modal').text();
    	var thisProject = $('#project_id').attr('value');
    	var original_submit_text = $('#submit-modal').html();

		switch($('#class-name').val()){

			case 'classifiers':
			  if(validateClassifier()){
			  $('#submit-modal').html("Loading...");
			  $('#classifier-errors').hide();
			  
			  let [source_domain, adaptive_heuristic_name, adaptive_heuristic_parameters, use_pca, feature_category, semantic_features, ahpo_name, ahpo_parameters, num_meta_alert_threshold] = getClassifierValues();

			  $.ajax({
					type: "POST",
					url: "/modals/classifier/create",
					contentType: 'application/json',
					data: JSON.stringify({
						classifier_instance_name: $('#classifier_name').val(),
						classifier_type: classifier_type,
						project_id: thisProject,
						source_domain: source_domain,
						adaptive_heuristic_name: adaptive_heuristic_name,
						adaptive_heuristic_parameters: adaptive_heuristic_parameters,
						use_pca: use_pca,
						feature_category: feature_category,
						semantic_features: semantic_features,
						ahpo_name: ahpo_name,
                                                ahpo_parameters: ahpo_parameters,
                                                num_meta_alert_threshold: num_meta_alert_threshold,
                                                scaife_classifier_id: classifier_id
					}),
					datatype: "json",
					success: function(result){
						$('#classifier-errors').hide();
						$('#modal-placement').modal('toggle');
						$('#submit-modal').html(original_submit_text);
						window.location.reload();
					},
					error: function(error_obj){
                        //error_status = error_obj.responseJSON.status
                        error_message = error_obj.responseJSON.message

                        $('#classifier-errors').html(error_message);
                        $('#classifier-errors').show();
                        $('#submit-modal').html(original_submit_text);
                        return false;
					}
				});
			  }
			  break;

			case 'existing-classifier':

		      var classifier_id = $('#classifier_id').text();
		      var classifier_type = $('#label-modal').text();

		      if(validateClassifier()){
		    	  
	    	  $('#submit-modal').html("Loading...");
	    	  
			  let [source_domain, adaptive_heuristic_name, adaptive_heuristic_parameters, use_pca, feature_category, semantic_features, ahpo_name, ahpo_parameters, num_meta_alert_threshold] = getClassifierValues();

			  $.ajax({
					type: "POST",
					url: "/modals/classifier/edit",
					contentType: 'application/json',
					data: JSON.stringify({
						classifier_instance_name: $('#classifier_name').val(),
						classifier_type: classifier_type,
						source_domain: source_domain,
						project_id: thisProject,
						adaptive_heuristic_name: adaptive_heuristic_name,
						adaptive_heuristic_parameters: adaptive_heuristic_parameters,
						use_pca: use_pca,
						feature_category: feature_category,
						semantic_features: semantic_features,
						ahpo_name: ahpo_name,
                                                ahpo_parameters: ahpo_parameters,
                                                num_meta_alert_threshold: num_meta_alert_threshold,
                                                scaife_classifier_id: classifier_id
					}),
					datatype: "json",
					success: function(result){
						$('#classifier-errors').hide();
						$('#modal-placement').modal('toggle');
						$('#submit-modal').html(original_submit_text);
						window.location.reload();
					},
					error: function(xhr, status, err){
                        $('#classifier-errors').html("Unable to edit classifier");
                        $('#classifier-errors').show();
                        $('#submit-modal').html(original_submit_text);
                        return false;
					}
				});
			  }
		    break;

		    default: return false; //invalid modal type
		}

	});

    //--------------Delete current scheme in the modal-----------------------------------
	$('#modalForm').on('click', '#delete-modal', function(e){
		e.preventDefault();

		var pid = $('#project_id').attr('value');


		if(confirm("Are you sure?")){
		  var className = $('#class-name').val();

		  switch(className){

		    case 'existing-classifier':
				var scheme = $('#classifier_name').val();

				$.ajax({
					type: "POST",
					url: '/modals/classifier/delete',
					data: {
						project_id: pid,
						classifier_name: scheme
					},
					datatype: "html",
					success: function(result){
						$('#classifier-errors').hide();
						$('#modal-placement').modal('toggle');
						window.location.reload();
					},
					error: function(xhr, status, err){
						$('#classifier-errors').html("Unable to delete classifier");
                        $('#classifier-errors').show();
						 return false;
					}
				});
				break;

			default: return false; //invalid modal type
		  }
		}
	});

    /* ********************* CLASSIFIER MODALS ******************************************************* */
	/*List items selected in classifier modal*/
	$('#modalForm').on('click', '.list_item', function(e){
		$('.list_item').removeClass("active_item");
		$(e.target).addClass("active_item");
	});

	//Add projects to use in the classification
	$('#modalForm').on('click', '#add_button', function(e){
		var projectToAdd = $('#all_proj li.active_item');
		if(projectToAdd.text() != ""){
			$(' #all_proj li.active_item').remove();
			$('#all_proj .list_item').removeClass("active_item");
			$('#select_proj').append('<li class="list_item">' + projectToAdd.text() +'</li>');
		}
	});

	//Remove projects from the list to use in classification.
	$('#modalForm').on('click', '#remove_button', function(e){
		var projectToRemove = $('#select_proj li.active_item');
		if(projectToRemove.text() != ""){
			$('#select_proj li.active_item').remove();
			$('#select_proj .list_item').removeClass("active_item");
			$('#all_proj').append('<li class="list_item">' + projectToRemove.text() +'</li>');
		}
	});

	//Parse uploaded CSV and send it in an AJAX request
	$('#user-upload-form').on('submit', function(e){
		e.preventDefault();
		$('#upload-error').hide();

		var file = $('#column_upload')[0].files[0];
		var file_reader = new FileReader();
		var json_object = {};

		file_reader.onload = function(){
			var file_contents = file_reader.result;
			var rows = file_contents.split(/\r?\n/);
			var headers = rows[0].split(","); //first row should be user headers

			  for(var i=1; i<rows.length; i++){
				if(rows[i] == undefined || rows[i] === ""){
					continue;
				}
				var vals = rows[i].split(","); //values in this row
				  user_columns = {};

				if(!(vals[0] == undefined) || vals[0] != ""){
				  for (var j=1; j<vals.length; j++){
					  if(headers[j] == undefined || headers[j] === ""){
						  continue;
					  }
				      if(vals[j] == undefined || vals[0] === ""){
				        user_columns[headers[j].toString()] = 0;
				      }
				      else{
					    user_columns[headers[j].toString()] = vals[j];
					  }
					}

				  json_object[vals[0]] = user_columns;
				}
			   }

			  $.ajax({
					type: "POST",
					url: "/modals/userUpload",
					data: {
					  column_upload: JSON.stringify(json_object)
					},
					datatype: "json",
					success: function(result){
						$('#user-uploads').modal('toggle');
					},
					error: function(xhr, status, err){
		                $('#upload-error').html("Error occured in uploading the file.");
		                $('#upload-error').show();
					}
				});
		};

		file_reader.readAsText(file);
	});
}); //end $(document).ready

function validateClassifier(){
	//Make sure projects are selected
	  if($('#select_proj li').length <= 1){
		$('#classifier-errors').html("Please choose projects for the classifier");
		return false; //On failures populate an error and don't send form
	  }

	  if($('#classifier_name').val() == ""){
		  $('#classifier-errors').html("Please input a classifier name");
		  return false;
	  }

	  if($('#select_proj li').length <= 1){
			$('#classifier-errors').html("Please choose projects for the classifier");
			return false; //On failures populate an error and don't send form
	  }

	  return true;
}

function getClassifierValues(){
	var source_domain = '';
	  $('#select_proj .list_item').each(function(index){
		if(index != 0) {
			source_domain += ',';
		}
		source_domain += $(this).text();
	  });

	  var adaptive_heuristic_name = $('#ah ul .active a').text();
	  var adaptive_heuristic_parameters = '';
          var ahpo_parameters = '';
	  ahp_selector = '#ah .tab-content .active .ahList li';

	  if( $(ahp_selector).length > 0 ) {
		adaptive_heuristic_parameters = {};
		$(ahp_selector).each(function(){
			ahp_label = $(this).find('label').text();

            inputFields = $(this).find('input');
			if(inputFields.length > 1){
			  ahp_values = []
			  inputFields.each(function(){
				  ahp_values.push($(this).val());
			  })
			}else{
				ahp_values = inputFields.val();
			}
			adaptive_heuristic_parameters[ahp_label] = ahp_values;
		});
	  }

	  var ahpo_name = $('#ahpoSelects').find(':selected').text();
          var use_pca = $("#use_pca_checkbox").is(":checked");
          var feature_category = $('input[name=feature_radio_button]:checked').val()
          var semantic_features = $("#semantic_features_checkbox").is(":checked");
          var num_meta_alert_threshold = $('#numMetaAlertThreshold').val();

	  return [source_domain, adaptive_heuristic_name, adaptive_heuristic_parameters, use_pca, feature_category, semantic_features, ahpo_name, ahpo_parameters, num_meta_alert_threshold];
}

function openEditModal(thisClassifier){ //function helper to open the modal for an existing classifier
	var thisProject = $('#project_id').attr('value');

	$('#submit-modal').html("Edit Classifier");
	$('#label-modal').attr('title', "Upload data to train the classifier");

	//GET request to render modal body
	$.ajax({
		type: "GET",
		url: '/modals/classifier/view',
		data: {
			className: "classifiers existing-classifier",
			project_id: thisProject,
			chosen: thisClassifier
		},
		datatype: "html",
		success: function(result){
			$('#modal-body').html(result);
                        var modal_title = $('#label-modal').text()
                        if ("" === modal_title){
                            error_msg = "Failed to connect to SCAIFE servers"
                            $('#classifier-errors').html(error_msg);
                            $('#classifier-errors').show();
                        }
		},
		error: function(xhr, status, err){
			alert("ERROR: Closing popup window! "); //limit the response given to user for security
		    $('#modal-placement').modal('toggle'); //close modal window when failed to get it's body

		}
	});
}
