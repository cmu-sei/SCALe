# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

# Some coffeescript code... I don't think this is necessary anymore. 
jQuery ->
  $('.best_in_place').best_in_place()

$ -> 
  $('#diags td').click ->
    if($(this).attr("class") != "flag" && $(this).attr("class") != "verdict" && $(this).attr("class") != "notes" && $(this).attr("class") != "selectDiag")
      $(this).parent().find("div").toggleClass("show")

  $("#diags td.flag").click -> 
    $(this).find("span").click()

  $("#diags td.verdict").click -> 
    $(this).find("span").click()
