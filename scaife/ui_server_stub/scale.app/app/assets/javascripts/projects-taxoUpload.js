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

$(".projects.taxoUpload").ready(function() {
  taxo_upload_setup();
});

function taxo_upload_setup(form_element = null) {

  //console.log("taxo_upload_setup()");

  var form_element = form_element || $("#taxoUpload-form");
  var form_element_prefix = "#upload_taxos_"

  var add_list_selector = ".add-taxo-list";
  var remove_list_selector = ".remove-taxo-list";
  var add_button_selector = ".add-taxo-button";
  var remove_button_selector = ".remove-taxo-button";
  var submit_button_selector = ".taxoUpload-submit";

  var selected_items = {};

  function _item_id(e) {
    return $(e).attr('data-id');
  }

  function _add_item_form_selector(id) {
    return form_element_prefix + id;
  }

  function _is_not_item(e) {
    return !$(e).is(".list-item")
  }

  function _refresh_display() {
    var add_list = form_element.find(add_list_selector);
    add_list.find(".list-item").each(function() {
      selected_items[_item_id($(this))] ? $(this).hide() : $(this).show();
    });
    var remove_list = form_element.find(remove_list_selector);
    remove_list.find(".list-item").each(function() {
      selected_items[_item_id($(this))] ? $(this).show() : $(this).hide();
    });
  }

  form_element.find(add_list_selector).on("click", ".list-item", list_flat_multi_selector);
  form_element.find(remove_list_selector).on("click", ".list-item", list_flat_multi_selector);

  form_element.find(add_button_selector).click(function(e) {
    var add_list = form_element.find(add_list_selector);
    add_list.find(".list-active-item").each(function() {
      if (_is_not_item(this)) return;
      var item_id = _item_id($(this));
      selected_items[item_id] = item_id;
    });
    add_list.find("*").removeClass("list-active-item");
    _refresh_display();
  });

  form_element.find(remove_button_selector).click(function(e) {
    var remove_list = form_element.find(remove_list_selector);
    remove_list.find(".list-active-item").each(function() {
      if (_is_not_item(this)) return;
      var item_id = _item_id($(this));
      delete selected_items[item_id];
    });
    remove_list.find("*").removeClass("list-active-item");
    _refresh_display();
  });

  form_element.find(submit_button_selector).click(function(e) {
    /*
    if ($.isEmptyObject(mapped_items)) {
      alert("At least one language must be mapped");
      return false;
    }
    */
    var add_list = form_element.find(add_list_selector);
    $.each(selected_items, function(item_id, val) {
      if (!val) return;
      f = add_list.find(_add_item_form_selector(item_id));
      f.length && f.val(item_id);
    });
  });

  _refresh_display();

}
