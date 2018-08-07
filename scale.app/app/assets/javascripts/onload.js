// Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved. See COPYRIGHT file for details.

// This file defines the onload function, which will run on every page
window.onload = function() {
  // We hide any loaders and overlays
  $("#loader, #overlay").hide();

  // Ensure that these buttons trigger the loader
  $("#create_database_button, #create_project_button").click(function(){
    $("#loader").show();
  });
  $("input[value='Filter']").click(function() {
    $("#loader").show();
  });

  // Click the filter button on load to start hte loading of project
  // diagnostics
  $("input[value='Filter']").click();

  // Hack to make the cursor "stick" to the split divider
  $("body").mousedown(function(){
  	$("#overlay").show();
  });
  $("body").mouseup(function(){
  	$("#overlay").hide();
  });
  
  // Initialize the jquery UI modal
  $('.modal').dialog({
    closeText: "Close",
    position: {my: "right", at:"right-2% center-25%", of: $("#upper")},
    width: 700,
    maxHeight: 400,
    zIndex:7
  }); 
  $(".modal").dialog("close");
 }
