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

$(".projects.langMap").ready(function() {
  lang_map_setup();
});

function lang_map_setup(form_element = null) {

  //console.log("lang_map_setup()");

  form_element = form_element || $("#langMap-form");
  var form_element_prefix = "#map_langs_"

  var src_list_selector = ".src-lang-list";
  var tgt_list_selector = ".tgt-lang-list";
  var map_list_selector = ".map-lang-list";
  var map_button_selector = ".map-lang-button";
  var unmap_button_selector = ".unmap-lang-button";
  var submit_button_selector = ".langMap-submit";

  var mapped_items = {};

  function _item_id(e) {
    return $(e).attr('data-id');
  }

  function _mapped_item_form_selector(id) {
    return form_element_prefix + id
  }

  function _is_not_item(e) {
    return (!($(e).is(".list-item") || $(e).is(".sublist-item")) || $(e).is(".sublist-all"));
  }

 function _refresh_list_display() {
    var src_list = form_element.find(src_list_selector);
    src_list.find(".sublist-item").each(function() {
      mapped_items[_item_id($(this))] ? $(this).hide() : $(this).show();
    });
    maybe_toggle_main_list_item(src_list);
   var map_list = form_element.find(map_list_selector);
    map_list.find(".list-item").each(function() {
      mapped_items[_item_id($(this))] ? $(this).show() : $(this).hide();
    });
  }

  form_element.find(src_list_selector).on("click", ".list-item", list_multi_selector);
  form_element.find(src_list_selector).on("click", ".sublist-item", sublist_multi_selector);
  form_element.find(tgt_list_selector).on("click", ".list-item", list_single_selector);
  form_element.find(map_list_selector).on("click", ".list-item", list_flat_multi_selector);

  $(map_button_selector).click(function(e) {
    var src_list = form_element.find(src_list_selector);
    var tgt_list = form_element.find(tgt_list_selector);
    var map_list = form_element.find(map_list_selector);
    var tgt_li = tgt_list.find(".list-item.list-active-item").first();
    var tgt_id = _item_id(tgt_li);
    src_list.find(".sublist-item.list-active-item").each(function() {
      if (_is_not_item(this)) return;
      var item_id = _item_id(this);
      mapped_items[item_id] = tgt_id;
      var tgt_elm = map_list.find("#tgt-" + item_id);
      tgt_elm.text(tgt_li.text());
    });
    src_list.find("*").removeClass("list-active-item");
    tgt_list.find("*").removeClass("list-active-item");
    _refresh_list_display();
  });

  $(unmap_button_selector).click(function(e) {
    var map_list = form_selector.find(map_list_selector);
    map_list.find(".list-item.list-active-item").each(function() {
      if (_is_not_item(this)) return;
      item_id = _item_id(this);
      delete mapped_items[item_id];
      $(this).find("tgt-" + item_id).text("");
    });
    map_list.find("*").removeClass("list-active-item");
    _refresh_list_display();
  });

  $(submit_button_selector).click(function(e) {
    /*
    if ($.isEmptyObject(mapped_items)) {
      alert("At least one language must be mapped");
      return false;
    }
    */
    var src_list = form_element.find(src_list_selector);
    var tgt_list = form_element.find(tgt_list_selector);
    $.each(mapped_items, function(src_id, tgt_id) {
      if (!tgt_id) return;
      f = src_list.find(_mapped_item_form_selector(src_id));
      f.length && f.val(tgt_id);
    });
    src_list.find("*").removeClass("list-active-item");
    tgt_list.find("*").removeClass("list-active-item");
  });

}
