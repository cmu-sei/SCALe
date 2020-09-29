// <legal>
// SCALe version r.6.2.2.2.A
// 
// Copyright 2020 Carnegie Mellon University.
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

    /* ********************* CODE LANGUAGE SELECTION ******************************************************* */
	/*List items selected in database creation page*/
	$('#code_languages').on('click', '.list_item', function(e){
		$('.list_item').removeClass("active_item");
		$(e.target).addClass("active_item");
	});

	//Add languages to use in database creation
	$('#code_languages').on('click', '#add_language_button', function(e){
		var languageToAdd = $('#all_lang li.active_item');
		if(languageToAdd.text() != ""){
			$('#all_lang li.active_item').remove();
			$('#all_lang .list_item').removeClass("active_item");
			$('#select_lang').append('<li class="list_item">' + languageToAdd.text() +'</li>');
		}
	});

	//Remove languages from the list to use in database create
	$('#code_languages').on('click', '#remove_language_button', function(e){
		var languageToRemove = $('#select_lang li.active_item');
		if(languageToRemove.text() != ""){
			$('#select_lang li.active_item').remove();
			$('#select_lang .list_item').removeClass("active_item");
			$('#all_lang').append('<li class="list_item">' + languageToRemove.text() +'</li>');
		}
	});
});
