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

$(".projects.taxoSelect").ready(function() {
  taxo_select_setup();
});

function taxo_select_setup(form_element = null, tools2taxos = null, project_taxos = null) {

  //console.log("taxo_select_setup()");

  form_element = form_element || $("#taxoSelect-form");

  var add_list_selector = ".add-taxo-list";
  var remove_list_selector = ".remove-taxo-list";
  var add_button_selector = ".add-taxo-button";
  var remove_button_selector = ".remove-taxo-button";

  var selected_items = {};
  var deselected_items = {};

  function _item_id(e) {
    return $(e).attr('data-id');
  }

  function _add_item_form_selector(id) {
    return "#select_taxos_" + id;
  }

  function _remove_item_form_selector(id) {
    return "#deselect_taxos_" + id;
  }

  function _is_not_item(e) {
    return !$(e).is(".list-item");
  }

  function _highlight_suggested() {
    if (! tools2taxos) return;
    var add_list = form_element.find(add_list_selector);
    var remove_list = form_element.find(remove_list_selector);
    highlight_suggested_taxos(tools2taxos, project_taxos, add_list, remove_list);
  }

  function _refresh_display() {
    var add_list = form_element.find(add_list_selector);
    var remove_list = form_element.find(remove_list_selector);
    add_list.find(".list-item").each(function() {
      if (_is_not_item(this)) return;
      var item_id = _item_id($(this));
      if ($(this).is(".orig-item")) {
        f = add_list.find(_add_item_form_selector(item_id));
        if (selected_items[item_id]) {
          $(this).hide();
          f.val(item_id);
        }
        else {
          $(this).show();
          f.val("");
        }
      }
      else {
        deselected_items[item_id] ? $(this).show() : $(this).hide();
      }
    });
    remove_list.find(".list-item").each(function() {
      var item_id = _item_id($(this));
      if ($(this).is(".orig-item")) {
        f = remove_list.find(_remove_item_form_selector(item_id));
        if (deselected_items[item_id]) {
          $(this).hide();
          f.val(item_id);
        }
        else {
          $(this).show();
          f.val("");
        }
      }
      else {
        selected_items[item_id] ? $(this).show() : $(this).hide();
      }
    });
    _highlight_suggested();
  }

  function refresh_on_select(e) {
    list_flat_multi_selector(e);
    _highlight_suggested();
  }

  form_element.find(add_list_selector).on("click", ".list-item", refresh_on_select);
  form_element.find(remove_list_selector).on("click", ".list-item", refresh_on_select);

  form_element.find(add_button_selector).click(function(e) {
    var add_list = form_element.find(add_list_selector);
    var remove_list = form_element.find(remove_list_selector);
    add_list.find(".list-active-item").each(function() {
      if (_is_not_item(this)) return;
      item_id = _item_id($(this));
      if ($(this).is(".orig-item")) {
        selected_items[item_id] = item_id;
      }
      else {
        delete deselected_items[item_id];
      }
    });
    add_list.find("*").removeClass("list-active-item");
    _refresh_display(add_list);
  });

  form_element.find(remove_button_selector).click(function(e) {
    var remove_list = form_element.find(remove_list_selector);
    var add_list = form_element.find(add_list_selector);
    remove_list.find(".list-item.list-active-item").each(function() {
      item_id = _item_id($(this));
      if ($(this).is(".orig-item")) {
        deselected_items[item_id] = item_id;
      }
      else {
        delete selected_items[item_id];
      }
    });
    remove_list.find("*").removeClass("list-active-item");
    _refresh_display();
  });

  _refresh_display();

}
