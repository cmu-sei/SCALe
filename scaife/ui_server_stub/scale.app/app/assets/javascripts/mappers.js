// <legal>
// SCALe version r.6.5.5.1.A
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

/* primarily for language/tool upload, mapping, etc */

// allow selections from entire list and sublists
function list_multi_selector(e) {
  // deactivate list items with no remaining sublist selections
  //console.log("list_multi_selector");
  $(e.currentTarget).parent().find(".list-item").each(function() {
    if ($(this).is($(e.target))) return;
    if ($(this).next().find(".sublist-item.list-active-item").length == 0) {
      $(this).removeClass("list-active-item");
    }
    else {
      $(this).addClass("list-active-item");
    }
  });
  $(e.currentTarget).addClass("list-active-item");
  if ($(e.currentTarget).attr("aria-expanded") == "true") {
    if ($(e.currentTarget).next().find(".sublist-item.list-active-item").length == 0) {
      $(e.currentTarget).removeClass("list-active-item");
    }
  }
}

// select one, more, or all items in a sublist
function sublist_multi_selector(e) {
  //console.log("sublist_multi_selector");
  if ($(e.currentTarget).hasClass("sublist-all")) {
    if ($(e.currentTarget).hasClass("list-active-item")) {
      $(e.currentTarget).parent().find(".sublist-item").removeClass("list-active-item");
      $(e.currentTarget).removeClass("list-active-item");
    }
    else {
      $(e.currentTarget).parent().find(".sublist-item").addClass("list-active-item");
      $(e.currentTarget).addClass("list-active-item");
    }
  }
  else {
    if ($(e.currentTarget).hasClass("list-active-item")) {
      $(e.currentTarget).parent().find(".sublist-all").removeClass("list-active-item");
    }
    $(e.currentTarget).toggleClass("list-active-item");
  }
}

// just select one at a time
function list_single_selector(e) {
  //console.log("single select");
  $(e.currentTarget).toggleClass("list-active-item");
  $(e.currentTarget).parent().find(".list-item").each(function() {
    if (! $(this).is($(e.currentTarget))) {
      $(this).removeClass("list-active-item");
    }
  });
}

// flat list, multiple allowed
function list_flat_multi_selector(e) {
  //console.log("multi select");
  $(e.currentTarget).toggleClass("list-active-item");
}

/* these functions are for handling hide/show interactions on sublists */

function maybe_toggle_main_list_item(lst) {
  lst.find(".list-item").each(function() {
    var hide = true;
    $(this).next().find(".sublist-item").each(function() {
      if ($(this).is(".sublist-all")) return;
      if ($(this).css("display") == "block") {
        hide = false;
      }
    });
    // toggle the expand link as well as the div
    if (hide) {
      $(this).hide();
      $(this).next().collapse("hide");
      $(this).next().find(".list-unstyled-sublist").hide();
    }
    else {
      $(this).show();
      $(this).next().find(".list-unstyled-sublist").show();
      if ($(this).attr("aria-expanded") == "true") {
        $(this).next().collapse('show');
      }
    }
  });
}

function highlight_suggested_taxos(tools2taxos, project_taxos, add_list = null, remove_list = null) {
  //console.log("highlight_suggested_taxos");
  if (! tools2taxos) return;
  if (! add_list && ! remove_list) return;
  function _highlight_taxo(taxo_id) {
    var sel = 'tr[data-id="' + taxo_id + '"]';
    if (add_list) {
      if (! add_list.find(sel).hasClass("list-active-item")) {
        add_list.find(sel).addClass("suggested");
      }
    }
    if (remove_list) {
      if (! remove_list.find(sel).hasClass("list-active-item")) {
        remove_list.find(sel).addClass("suggested");
      }
    }
  }
  if (add_list) add_list.find(".list-item").removeClass("suggested");
  if (remove_list) remove_list.find(".list-item").removeClass("suggested");
  // relative to main page
  $('input[name^="selectedTools"').each(function() {
    if (! $(this).is(":checked")) return;
    var tool_group = $(this).val();
    var input = $(this).parent().next().find('input[name^="tool_versions"]');
    if (input.length == 0) {
      input = $(this).parent().next().find('select[name^="tool_versions"] option:selected');
    }
    var ver = input.val();
    $.each(tools2taxos[tool_group][input.val()], function(i, taxo_id) {
      _highlight_taxo(taxo_id);
    });
  });
  if (project_taxos) {
    // do these no matter what, they've turned up during analysis already
    $.each(project_taxos, function(i, taxo_id) {
      _highlight_taxo(taxo_id);
    });
  }
}
