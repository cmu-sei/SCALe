# <legal>
# SCALe version r.6.7.0.0.A
# 
# Copyright 2021 Carnegie Mellon University.
# 
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING
# INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON
# UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR
# IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF
# FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS
# OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT
# MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT,
# TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# 
# Released under a MIT (SEI)-style license, please see COPYRIGHT file or
# contact permission@sei.cmu.edu for full terms.
# 
# [DISTRIBUTION STATEMENT A] This material has been approved for public
# release and unlimited distribution.  Please see Copyright notice for
# non-US Government use and distribution.
# 
# DM19-1274
# </legal>

require "test_helper"

class ScaifeApiDatahubTest < ActiveSupport::TestCase

  # list_projects

  test "SCAIFE_list_projects returns 200" do
    x_access_token = "valid_access_token"
    code = 200
    stub_and_test_list_projects(x_access_token, code)
  end

  test "SCAIFE_list_projects returns 404" do
    x_access_token = "valid_access_token"
    code = 404
    stub_and_test_list_projects(x_access_token, code)
  end

  test "SCAIFE_list_projects returns 400" do
    x_access_token = "valid_access_token"
    code = 400
    stub_and_test_list_projects(x_access_token, code)
  end

  # list_packages

  test "SCAIFE_list_packages returns 200" do
    x_access_token = "valid_access_token"
    code = 200
    stub_and_test_list_packages(x_access_token, code)
  end

  test "SCAIFE_list_packages returns 404" do
    x_access_token = "valid_access_token"
    code = 404
    stub_and_test_list_packages(x_access_token, code)
  end

  test "SCAIFE_list_packages returns 400" do
    x_access_token = "valid_access_token"
    code = 400
    stub_and_test_list_packages(x_access_token, code)
  end

  # list_languages

  test "SCAIFE_list_languages returns 200" do
    x_access_token = "valid_access_token"

    body = [].to_json
    code = 200
    stub_and_test_list_languages(x_access_token, body, code)
  end

  test "SCAIFE_list_languages returns 404" do
    x_access_token = "valid_access_token"
    body = "Languages Unavailable"
    code = 404
    stub_and_test_list_languages(x_access_token, body, code)
  end

  test "SCAIFE_list_languages returns 400" do
    x_access_token = "valid_access_token"
    body = "Invalid Request"
    code = 400
    stub_and_test_list_languages(x_access_token, body, code)
  end

  # create_language

  test "SCAIFE_create_language returns 200" do
    x_access_token = "valid_access_token"
    language_name = "language name"
    language_version = "languager.version"
    body = { }.to_json
    code = 200
    stub_and_test_create_language(x_access_token,
      language_name, language_version, body, code)
  end

  test "SCAIFE_create_language returns 400" do
    x_access_token = "valid_access_token"
    language_name = "language name"
    language_version = "languager.version"
    body = "Invalid Request"
    code = 400
    stub_and_test_create_language(x_access_token,
      language_name, language_version, body, code)
  end

  # list_tools

  test "SCAIFE_list_tools returns 200" do
    x_access_token = "valid_access_token"
    body = [].to_json
    code = 200
    stub_and_test_list_tools(x_access_token, body, code)
  end

  test "SCAIFE_list_tools returns 404" do
    x_access_token = "valid_access_token"
    body = "Tools Unavailable"
    code = 404
    stub_and_test_list_tools(x_access_token, body, code)
  end

  test "SCAIFE_list_tools returns 400" do
    x_access_token = "valid_access_token"
    body = "Invalid Request"
    code = 400
    stub_and_test_list_tools(x_access_token, body, code)
  end

  # upload_tool

  test "SCAIFE_upload_tool returns 200" do
    x_access_token = "valid_access_token"
    tool_name = "tool name"
    tool_version = "tool.version"
    author_source = "SCALe_user"
    category = "METRICS"
    platforms = ["c", "cpp"]
    code_language_ids = ["5da60a91649f74df25cc9daf", "6da60a91649f74df25cc9daf"]
    checker_mappings = []
    checker_names = ["checker_one", "checker_two", "checker_three", "checker_four"]
    code_metrics_headers = ["column1", "column2", "column3"]
    body = { }.to_json
    code = 200
    stub_and_test_upload_tool(x_access_token,
      tool_name, tool_version, category, platforms, code_language_ids,
      checker_mappings, checker_names, code_metrics_headers, author_source,
      body, code)
  end

  test "SCAIFE_upload_tool returns 400" do
    x_access_token = "valid_access_token"
    tool_name = "tool name"
    tool_version = "tool.version"
    author_source = "SCALe_user"
    category = "METRICS"
    platforms = ["c", "cpp"]
    code_language_ids = ["5da60a91649f74df25cc9daf", "6da60a91649f74df25cc9daf"]
    checker_mappings = []
    checker_names = ["checker_one", "checker_two", "checker_three", "checker_four"]
    code_metrics_headers = ["column1", "column2", "column3"]
    body = "Unable to Upload Tool Information"
    code = 400
    stub_and_test_upload_tool(x_access_token,
      tool_name, tool_version, category, platforms, code_language_ids,
      checker_mappings, checker_names, code_metrics_headers, author_source,
      body, code)
  end

  # list_taxonomies

  test "SCAIFE_list_taxonomies returns 200" do
    x_access_token = "valid_access_token"
    body = [].to_json
    code = 200
    stub_and_test_list_taxonomies(x_access_token, body, code)
  end

  test "SCAIFE_list_taxonomies returns 404" do
    x_access_token = "valid_access_token"
    body = "Taxonomies Unavailable"
    code = 404
    stub_and_test_list_taxonomies(x_access_token, body, code)
  end

  test "SCAIFE_list_taxonomies returns 400" do
    x_access_token = "valid_access_token"
    code = 400
    body = "Invalid Request"
    stub_and_test_list_taxonomies(x_access_token, body, code)
  end

  # create_taxonomy

  test "SCAIFE_create_taxonomy returns 200" do
    x_access_token = "valid_access_token"
    taxonomy_name = "taxonomy name"
    taxonomy_version = "taxonomy version"
    description = "SCAIFE Taxonomy"
    author_source = "SCALe_user"
    code_language_ids = ["5da60a91649f74df25cc9daf", "6da60a91649f74df25cc9daf"]
    conditions = [{"code_language_ids": code_language_ids, "condition_name": "Condition 1 Name", "title": "Condition 1 Title"}, {"code_language_ids": code_language_ids, "condition_name": "Condition 1 Name", "title": "Condition 1 Title"}]
    body = { }.to_json
    code = 200
    stub_and_test_create_taxonomy(x_access_token,
      taxonomy_name, taxonomy_version, description, conditions, author_source,
      body, code)
  end

  test "SCAIFE_create_taxonomy returns 400" do
    x_access_token = "valid_access_token"
    taxonomy_name = "taxonomy name"
    taxonomy_version = "taxonomy version"
    description = "SCAIFE Taxonomy"
    author_source = "SCALe_user"
    code_language_ids = ["5da60a91649f74df25cc9daf", "6da60a91649f74df25cc9daf"]
    conditions = [{"code_language_ids": code_language_ids, "condition_name": "Condition 1 Name", "title": "Condition 1 Title"}, {"code_language_ids": code_language_ids, "condition_name": "Condition 1 Name", "title": "Condition 1 Title"}]
    body = { }.to_json
    code = 400
    stub_and_test_create_taxonomy(x_access_token,
      taxonomy_name, taxonomy_version, description, conditions, author_source,
      body, code)
  end
  
  # edit_taxonomy
  
  test "SCAIFE_edit_taxonomy returns 200" do
      x_access_token = "valid_access_token"
      taxonomy_id = "5e7819ba6b61dbf75b878ec2"
      code_language_ids = ["5da60a91649f74df25cc9daf", "6da60a91649f74df25cc9daf"]
      conditions = [{"code_language_ids": code_language_ids, "condition_name": "Condition 1 Name", "title": "Condition 1 Title"}, {"code_language_ids": code_language_ids, "condition_name": "Condition 1 Name", "title": "Condition 1 Title"}]
      body = [].to_json
      code = 200
      stub_and_test_edit_taxonomy(x_access_token,
        taxonomy_id, conditions, body, code)
  end
  
  test "SCAIFE_edit_taxonomy returns 404" do
      x_access_token = "valid_access_token"
      taxonomy_id = "000000000000000000000000"
      code_language_ids = ["5da60a91649f74df25cc9daf", "6da60a91649f74df25cc9daf"]
      conditions = [{"code_language_ids": code_language_ids, "condition_name": "Condition 1 Name", "title": "Condition 1 Title"}, {"code_language_ids": code_language_ids, "condition_name": "Condition 1 Name", "title": "Condition 1 Title"}]
      body = "Taxonomy Information Unavailable"
      code = 404
      stub_and_test_edit_taxonomy(x_access_token,
        taxonomy_id, conditions, body, code)
  end

  # get_tool_data

  test "SCAIFE_get_tool_data returns 200" do
    x_access_token = "valid_access_token"
    tool_id = "5da60a91649f74df25cc9daf"
    code = 200
    stub_and_test_get_tool_data(x_access_token, tool_id, code)
  end

  test "SCAIFE_get_tool_data returns 404" do
    x_access_token = "valid_access_token"
    tool_id = "6da60a91649f74df25cc9daf"
    code = 404
    stub_and_test_get_tool_data(x_access_token, tool_id, code)
  end

  test "SCAIFE_get_tool_data returns 400" do
    x_access_token = "valid_access_token"
    tool_id = "6da60a91649f74df25cc9daf"
    code = 400
    stub_and_test_get_tool_data(x_access_token, tool_id, code)
  end


  # edit_tool

  #TODO: WebMock does not support matching body for multipart/form-data requests yet

  #test "SCAIFE_edit_tool returns 200" do
  #  x_access_token = "valid_access_token"
  #  tool_id = "5da60a91649f74df25cc9daf"
  #  checker_mappings_file_path = File.join(Dir.pwd, "/test-input/sample_scale_checker_mappings.csv")
  #  body = { }.to_json
  #  code = 200
  #  stub_and_test_edit_tool(x_access_token,
  #    tool_id, checker_mappings_file_path,
  #    body, code)
  #end

  # test "SCAIFE_edit_tool returns 400" do
  #  x_access_token = "valid_access_token"
  #  tool_id = "6da60a91649f74df25cc9daf"
  #  checker_mappings_file_path = File.join(Dir.pwd, "/test-input/sample_scale_checker_mappings.csv")
  #  body = { }.to_json
  #  code = 400
  #  stub_and_test_edit_tool(x_access_token,
  #    tool_id, checker_mappings_file_path,
  #    body, code)
  #end

  # create_project

  test "SCAIFE_create_project returns 200" do
    x_access_token = "valid_access_token"
    project_name = "project name"
    project_description = "SCAIFE project"
    author_source = "author"
    package_id = "6da60a91649f74df25cc9fba"
    meta_alerts = {}
    taxonomy_ids = ["5da60a91649f74df25cc9daf", "6da60a91649f74df25cc9daf"]
    body = { }.to_json
    code = 200
    stub_and_test_create_project(x_access_token,
      project_name, project_description, author_source, package_id, meta_alerts, taxonomy_ids,
      body, code)
  end

  test "SCAIFE_create_project returns 400" do
    x_access_token = "valid_access_token"
    project_name = "project name"
    project_description = "SCAIFE project"
    author_source = "author"
    package_id = "6da60a91649f74df25cc9fba"
    meta_alerts = {}
    taxonomy_ids = ["5da60a91649f74df25cc9daf", "6da60a91649f74df25cc9daf"]
    body = { }.to_json
    code = 400
    stub_and_test_create_project(x_access_token,
      project_name, project_description, author_source, package_id, meta_alerts, taxonomy_ids,
      body, code)
  end

  # create_package

  test "SCAIFE_create_package returns 200" do
    x_access_token = "valid_access_token"
    package_name = "package name"
    package_description = "SCAIFE package"
    author_source = "author"
    code_language_ids = ["5da60a91649f74df25cc9daf", "6da60a91649f74df25cc9daf"]
    tool_ids = ["6da60a91649f74df25cc9fba", "760a91649f74df25cc9fhg"]
    code_source_url = "https://www.sei.cmu.edu"
    source_file_url = "https://www.sei.cmu.edu"
    source_function_url = "https://www.sei.cmu.edu"
    test_suite_id = "5da60a91649f74df25cc9daf"
    tool_id = "6da60a91649f74df25cc9fba"
    checker_id = "6da60a91649f74df25cc9daf"
    alert_code_language = {"language": "C++", "version": "14"}
    message = {"line_start": "100", "line_end": "110", "filepath": "/sample/file/path"}
    secondary_message = {"line_start": "100", "line_end": "110", "filepath": "/sample/file/path", "message_text": "secondary message"}
    alert1 = {"code_language": code_language_ids[0], "tool_id": tool_id, "checker_id": checker_id, "primary_message": message, "secondary_messages": [secondary_message]}

    body = { }.to_json
    code = 200
    stub_and_test_create_package(x_access_token,
      package_name, package_description, author_source, code_language_ids,
      code_source_url, source_file_url, source_function_url, test_suite_id, [alert1], tool_ids,
      body, code)
  end

  test "SCAIFE_create_package returns 400" do
    x_access_token = "valid_access_token"
    package_name = "package name"
    package_description = "SCAIFE package"
    author_source = "author"
    code_language_ids = ["5da60a91649f74df25cc9daf", "6da60a91649f74df25cc9daf"]
    tool_ids = ["6da60a91649f74df25cc9fba", "760a91649f74df25cc9fhg"]
    code_source_url = "https://www.sei.cmu.edu"
    source_file_url = "https://www.sei.cmu.edu"
    source_function_url = "https://www.sei.cmu.edu"
    test_suite_id = "5da60a91649f74df25cc9daf"
    tool_id = "6da60a91649f74df25cc9fba"
    checker_id = "6da60a91649f74df25cc9daf"
    alert_code_language = {"language": "C++", "version": "14"}
    message = {"line_start": "100", "line_end": "110", "filepath": "/sample/file/path"}
    secondary_message = {"line_start": "100", "line_end": "110", "filepath": "/sample/file/path", "message_text": "secondary message"}
    alert1 = {"code_language": code_language_ids[0], "tool_id": tool_id, "checker_id": checker_id, "primary_message": message, "secondary_messages": [secondary_message]}

    body = { }.to_json
    code = 400
    stub_and_test_create_package(x_access_token,
      package_name, package_description, author_source, code_language_ids,
      code_source_url, source_file_url, source_function_url, test_suite_id, [alert1], tool_ids,
      body, code)
  end

  # create_test_suite

  test "SCAIFE_create_test_suite returns 200" do
    x_access_token = "valid_access_token"
    test_suite_name = "test suite name"
    test_suite_type = "juliet"
    test_suite_version = "1.0"
    test_suite_type = "juliet"
    manifest_urls = ["https://www.sei.cmu.edu", "https://www.cmu.edu"]
    use_license_file_url = "https://www.cert.org"
    author_source = "author"
    code_languages = [{"language": "C++", "version": "14"}, {"language": "Java", "version": "8"}]
    body = { }.to_json
    code = 200

    stub_and_test_create_test_suite(x_access_token, test_suite_name, test_suite_version, test_suite_type, manifest_urls, use_license_file_url, author_source, code_languages, body, code)

  end

  test "SCAIFE_create_test_suite returns 400" do
    x_access_token = "valid_access_token"
    test_suite_name = "test suite name"
    test_suite_type = "juliet"
    test_suite_version = "1.0"
    test_suite_type = "juliet"
    manifest_urls = ["https://www.sei.cmu.edu", "https://www.cmu.edu"]
    use_license_file_url = "https://www.cert.org"
    author_source = "author"
    code_languages = [{"language": "C++", "version": "14"}, {"language": "Java", "version": "8"}]
    body = { }.to_json
    code = 400
    stub_and_test_create_test_suite(x_access_token, test_suite_name, test_suite_version, test_suite_type, manifest_urls, use_license_file_url, author_source, code_languages, body, code)
    end

end
