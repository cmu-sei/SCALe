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

function _val_present(val) {
  return (val != null && val != "" && val !== [] && val !== {});
}

function failForm(msg) {
  alert(msg);
  $("#loader").hide();
  return false;
}

function isValidArchive(fname) {
  return (
    fname.endsWith(".zip")
    || fname.endsWith(".tgz")
    || fname.endsWith(".tar.gz")
  );
}

function isValidManifest(fname) {
  return ((isValidArchive(fname) || fname.endsWith(".xml")))
}

function toURI(url) {
  var uri = document.createElement('a');
  uri.href = url;
  return uri;
}

function validateProject() {
  var is_test_suite = $('#project_is_test_suite_true').prop('checked') ? true : false;
  source_uploaded = $("#project_source_file").val() != "" ? true : false;
  if (is_test_suite) {
    if (! $("#project_test_suite_name").val()) {
      return failForm("Test suite name required.");
    }
    if (! $("#project_test_suite_version").val()) {
      return failForm("Test suite version required.");
    }
    var sard_id = $("#project_test_suite_sard_id").val()
    if (_val_present(sard_id) && !$.isNumeric(sard_id)) {
      return failForm("SARD ID must be an integer.");
    }
    if (!source_uploaded) {
      var src_elm = $("#file_source");
      var src_file = src_elm.val();
      var src_url = $.trim($("#project_source_url").val());
      $("#project_source_url").val(src_url)
      if ((! _val_present(src_file) && ! _val_present(src_url)) || (_val_present(src_file) && _val_present(src_url))) {
        return failForm("Archive source file or URL (but not both) required.");
      }
      if (_val_present(src_file)) {
        if (!isValidArchive(src_file)) {
          failForm("Invalid source archive format (.zip, .tgz, .tar.gz)");
          src_elm.replaceWith(src_elm.val('').clone(true));
          return false;
        }
      }
      //else if (_val_present(src_url)) {
      //  src_uri = toURI(src_url);
      //  if (!isValidArchive(src_uri.pathname)) {
      //    return failForm("Invalid source archive format (.zip, .tgz, .tar.gz).");
      //  }
      //}
    }
    var manifest_uploaded = $("#project_manifest_file").val() != "" ? true : false;
    var manifest_elm = $("#file_manifest_file");
    var manifest_file = manifest_elm.val();
    var manifest_url = $.trim($("#project_manifest_url").val());
    $("#project_manifest_url").val(manifest_url)
    if (manifest_uploaded) {
      // URL submitted on edit page without having cleared file val
      if (_val_present(manifest_file) && _val_present(manifest_url)) {
        return failForm("Manifest file and URL cannot both be specified.");
      }
    } else {
      // database page, both selected
      if ((! _val_present(manifest_file) && ! _val_present(manifest_url)) || (_val_present(manifest_file) && _val_present(manifest_url))) {
        return failForm("Manifest file or URL (but not both) required.");
      }
    }
    if (_val_present(manifest_file)) {
      if (!isValidManifest(manifest_file)) {
        failForm("Invalid manifest file format (.xml, .zip, .tgz, .tar.gz)");
        manifest_elm.replaceWith(manifest_elm.val('').clone(true));
        return false;
      }
    }
    return true;
  }
  else {
    valid = true;
    if (!source_uploaded) {
      src_elm = $("#file_source");
      src_file = src_elm.val();
      if (! _val_present(src_file)) {
        valid = failForm("Archive source file required.");
      }
      else if (!isValidArchive(src_file)) {
        valid = failForm("Invalid source archive format (.zip, .tgz, .tar.gz)");
        if (!valid) {
          src_elm.replaceWith(src_elm.val('').clone(true));
        }
      }
    }

    if($(".swamp_validity").is(":visible")) {
      //valid = failForm("Choose additional Tool Information for SWAMP uploads.");
      return false;
    }

    if (valid) {
      // clear test suite fields if submitting as non-test suite
      $(".test-suite-field").each(function(index) {
        $(this).val("");
      });
    }
    return valid;
  }
}
