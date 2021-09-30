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

ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment.rb', __FILE__)
require 'rails/test_help'
require 'minitest/reporters'
require 'simplecov'
require 'webmock/minitest'
require 'scaife/api/registration'
require 'scaife/api/statistics'
require 'scaife/api/datahub'
require 'scaife/api/prioritization'

Minitest::Reporters.use!
SimpleCov.start 'rails'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...

=begin

  Begin global test helpers

=end

  def basic_auth
    # Login to SCALe web app
    headers = {}
    headers["Accept"] = "text/javascript"

    post '/users/register-submit', as: :json,
         params: {
           firstname_field: "John",
           lastname_field: "Doe",
           org_field: "SEI",
           user_field: "test_user",
           password_field: "Test!abc123"
         },
         headers: headers,
         xhr: true

    assert_response :success
    return {} # empty headers
  end

  # create the test external db
  def create_test_ext_db
    db_dir =  Rails.configuration.x.external_db_dir.join(Rails.configuration.x.test_project_id.to_s)
    db = db_dir.join(Rails.configuration.x.external_db_basename)
    create_ext_db_script = File.join(Rails.root, "scripts", "create_scale_db.sql")
    cmd = "sqlite3 #{db} < #{create_ext_db_script}"

    Dir.mkdir(db_dir)
    db_file = File.new(db, "w")
    db_file.close
    system(cmd)

    return db, db_dir
  end

  # delete the given db path
  def delete_test_ext_db(db, db_dir)
    File.delete(db) if File.exist?(db)
    FileUtils.remove_dir(db_dir)
  end


  # bypass checking for pulsar, etc, during non-integration tests
  # ("non-integration tests" are tests that aren't integration tests)
  def with_offline_testing()
    original_state = Rails.configuration.x.offline_testing
    Rails.configuration.x.offline_testing = true
    yield
  ensure
    Rails.configuration.x.offline_testing = original_state
  end


=begin

  Begin SCAIFE method test helpers

=end
  def stub_and_test_register(first, last, org, user, pass, body, code)

    stub_request(:post, File.join(
      Rails.configuration.x.scaife.registration_module_url,
      Rails.configuration.x.scaife.register
    ))
      .with(
        body: {
          first_name: first,
          last_name: last,
          organization_name: org,
          username: user,
          password: pass
        }.to_json,
        headers: {
          'Accept'=>'application/json',
          'Content-Type'=>'application/json',
        }
      ).to_return(
        status: code,
        body: body,
        headers: {}
      )

    api = Scaife::Api::Registration::UIToRegistrationApi.new

    begin
      request_data = Scaife::Api::Registration::UserInformation.new(
        first_name: first,
        last_name: last,
        organization_name: org,
        username: user,
        password: pass
      )
      data, response_code, _headers =
        api.register_users_with_http_info(request_data)
      if body.nil? or data.class == String
        response_body = data
      else
        response_body = data.to_json
      end
    rescue Scaife::Api::Registration::ApiError => e
      response_code = e.code
      response_body = e.response_body
    end

    assert_equal code, response_code
    body.nil? ? assert_nil(response_body) : assert_equal(body, response_body)
  end

  def stub_and_test_login(user, pass, body, code)

    stub_request(:post, File.join(
      Rails.configuration.x.scaife.registration_module_url,
      Rails.configuration.x.scaife.login
    ))
      .with(
        body: {
          username: user,
          password: pass
        }.to_json,
        headers: {
          #'Accept'=>'application/json',
          'Content-Type'=>'application/json',
        }
      ).to_return(
        status: code,
        body: body,
        headers: {}
      )

    api = Scaife::Api::Registration::UIToRegistrationApi.new

    begin
      creds = Scaife::Api::Registration::LoginCredentials.new(
        username: user,
        password: pass
      )
      data, response_code, _headers =
        api.login_user_with_http_info(creds)
      if body.nil? or data.class == String
        response_body = data
      else
        response_body = data.to_json
      end
    rescue Scaife::Api::Registration::ApiError => e
      response_code = e.code
      response_body = e.response_body
    end

    assert_equal code, response_code
    body.nil? ? assert_nil(response_body) : assert_equal(body, response_body)
  end

  def stub_and_test_logout(access_token, body, code)

    stub_request(:post, File.join(
      Rails.configuration.x.scaife.registration_module_url,
      Rails.configuration.x.scaife.logout
    ))
      .with(
        body: {
          access_token: access_token,
        }.to_json,
        headers: {
          # accept successful plain text message
          'Accept'=>'application/json',
          'Content-Type'=>'application/json',
          'x-access-token'=>access_token,
        }
      ).to_return(
        status: code,
        body: body,
        headers: {}
      )

    api = Scaife::Api::Registration::UIToRegistrationApi.new

    begin
      data, response_code, _headers =
        api.logout_user_with_http_info(access_token)
      if body.nil? or data.class == String
        response_body = data
      else
        response_body = data.to_json
      end
    end

    assert_equal code, response_code
    body.nil? ? assert_nil(response_body) : assert_equal(body, response_body)
  end

  def stub_and_test_get_access_token(server, login_token, body, code)
    stub_request(:get, File.join(
      Rails.configuration.x.scaife.registration_module_url,
      "servers",
      server
    ))
      .with(
        headers: {
          'x_access_token' => login_token,
          #'Accept'=>'application/json',
          'Content-Type'=>'application/json',
        }
      ).to_return(
        status: code,
        body: body,
        headers: {}
      )

    api = Scaife::Api::Registration::UIToRegistrationApi.new

    begin
      data, response_code, _headers =
        api.get_server_access_with_http_info(server, login_token)
      if body.nil? or data.class == String
        response_body = data
      else
        response_body = data.to_json
      end
    rescue Scaife::Api::Registration::ApiError => e
      response_code = e.code
      response_body = e.response_body
    end

    assert_equal code, response_code
    body.nil? ? assert_nil(response_body) : assert_equal(body, response_body)
  end

  def stub_and_test_list_prioritizations(x_access_token, p_id, body, code)
    stub_request(:get, File.join(
      Rails.configuration.x.scaife.prioritization_module_url,
      Rails.configuration.x.scaife.list_priority_schemes
    ))
      .with(
        headers: {
          'x_access_token' => x_access_token,
          #'Accept'=>'application/json',
          'Content-Type'=>'application/json',
        }
      ).to_return(
        status: code,
        body: body,
        headers: {}
      )

    api = Scaife::Api::Prioritization::UIToPrioritizationApi.new

    # no p_id
    begin
      data, response_code, _headers = \
        api.list_prioritizations_with_http_info(x_access_token)
      if body.nil? or data.class == String
        response_body = data
      else
        response_body = data.to_json
      end
    rescue Scaife::Api::Prioritization::ApiError => e
      response_code = e.code
      response_body = e.response_body
    end

    assert_equal code, response_code
    body.nil? ? assert_nil(response_body) : assert_equal(body, response_body)

    # with p_id
    begin
      data, response_code, _headers = \
        api.list_prioritizations_with_http_info(x_access_token, project_id: p_id)
      if body.nil? or data.class == String
        response_body = data
      else
        response_body = data.to_json
      end
    rescue Scaife::Api::Prioritization::ApiError => e
      response_code = e.code
      response_body = e.response_body
    end

    assert_equal code, response_code
    body.nil? ? assert_nil(response_body) : assert_equal(body, response_body)
  end

  def stub_and_test_create_prioritization(x_access_token,
        p_scheme_id, p_name, p_ids, formula, w_cols, is_global,
        is_remote, body, code)
    stub_request(:post, File.join(
      Rails.configuration.x.scaife.prioritization_module_url,
      Rails.configuration.x.scaife.create_priority_scheme
    ))
      .with(
        body: {
          priority_scheme_name: p_name,
          project_ids: p_ids,
          formula: formula,
          weighted_columns: w_cols,
          is_global: is_global,
          is_remote: is_remote
        }.to_json,
        headers: {
          'x_access_token' => x_access_token,
          #'Accept'=>'application/json',
          'Content-Type'=>'application/json',
        }
      ).to_return(
        status: code,
        body: body,
        headers: {}
      )

    api = Scaife::Api::Prioritization::UIToPrioritizationApi.new

    begin
      request_data = Scaife::Api::Prioritization::CreatePrioritizationData.new(
        priority_scheme_name: p_name,
        project_ids: p_ids,
        formula: formula,
        weighted_columns: w_cols,
        is_global: is_global,
        is_remote: is_remote
      )
      data, response_code, _headers = \
          api.create_prioritization_with_http_info(
              x_access_token, request_data)
      if body.nil? or data.class == String
        response_body = data
      else
        response_body = data.to_json
      end
    rescue Scaife::Api::Prioritization::ApiError => e
      response_code = e.code
      response_body = e.response_body
    end

    assert_equal code, response_code
    body.nil? ? assert_nil(response_body) : assert_equal(body, response_body)
  end

  def stub_and_test_update_prioritization(x_access_token,
          p_id, p_name, p_ids, formula, w_cols, body, code)
    stub_request(:put, File.join(
      Rails.configuration.x.scaife.prioritization_module_url,
      Rails.configuration.x.scaife.update_priority_scheme,
      p_id
    ))
      .with(
        body: hash_including({
          priority_scheme_name: p_name
        }),
        headers: {
          'x_access_token' => x_access_token,
          #'Accept'=>'application/json',
          'Content-Type'=>'application/json',
        }
      ).to_return(
        status: code,
        body: body,
        headers: {}
      )

    api = Scaife::Api::Prioritization::UIToPrioritizationApi.new

    begin
      # no optional args
      request_data = Scaife::Api::Prioritization::UpdatePriorityData.new(
        priority_scheme_name: p_name
      )
      data, response_code, _headers =
        api.update_prioritization_with_http_info(
          p_id, x_access_token, request_data)
      if body.nil? or data.class == String
        response_body = data
      else
        response_body = data.to_json
      end
    rescue Scaife::Api::Prioritization::ApiError => e
      response_code = e.code
      response_body = e.response_body
    end

    assert_equal code, response_code
    body.nil? ? assert_nil(response_body) : assert_equal(body, response_body)

    begin
      # formula included
      request_data = Scaife::Api::Prioritization::UpdatePriorityData.new(
        priority_scheme_name: p_name,
        formula: formula
      )
      data, response_code, _headers =
        api.update_prioritization_with_http_info(
          p_id, x_access_token, request_data)
      if body.nil? or data.class == String
        response_body = data
      else
        response_body = data.to_json
      end
    rescue Scaife::Api::Prioritization::ApiError => e
      response_code = e.code
      response_body = e.response_body
    end

    assert_equal code, response_code
    body.nil? ? assert_nil(response_body) : assert_equal(body, response_body)

    begin
      # w_cols included
      request_data = Scaife::Api::Prioritization::UpdatePriorityData.new(
        priority_scheme_name: p_name,
        weighted_columns: w_cols
      )
      data, response_code, _headers =
        api.update_prioritization_with_http_info(
          p_id, x_access_token, request_data)
      if body.nil? or data.class == String
        response_body = data
      else
        response_body = data.to_json
      end
    rescue Scaife::Api::Prioritization::ApiError => e
      response_code = e.code
      response_body = e.response_body
    end

    assert_equal code, response_code
    body.nil? ? assert_nil(response_body) : assert_equal(body, response_body)

    begin
      # p_ids included
      request_data = Scaife::Api::Prioritization::UpdatePriorityData.new(
        priority_scheme_name: p_name,
        project_ids: p_ids
      )
      data, response_code, _headers =
        api.update_prioritization_with_http_info(
          p_id, x_access_token, request_data)
      if body.nil? or data.class == String
        response_body = data
      else
        response_body = data.to_json
      end
    rescue Scaife::Api::Prioritization::ApiError => e
      response_code = e.code
      response_body = e.response_body
    end

    assert_equal code, response_code
    body.nil? ? assert_nil(response_body) : assert_equal(body, response_body)

    begin
      # all optional args included
      request_data = Scaife::Api::Prioritization::UpdatePriorityData.new(
        priority_scheme_name: p_name,
        formula: formula,
        weighted_columns: w_cols,
        project_ids: p_ids
      )
      data, response_code, _headers =
        api.update_prioritization_with_http_info(
          p_id, x_access_token, request_data)
      if body.nil? or data.class == String
        response_body = data
      else
        response_body = data.to_json
      end
    rescue Scaife::Api::Prioritization::ApiError => e
      response_code = e.code
      response_body = e.response_body
    end

    assert_equal code, response_code
    body.nil? ? assert_nil(response_body) : assert_equal(body, response_body)
  end

  def stub_and_test_get_prioritization(x_access_token,
          proj_id, ps_id, body, code)
    stub_request(:get, File.join(
      Rails.configuration.x.scaife.prioritization_module_url,
      Rails.configuration.x.scaife.get_priority_scheme,
      ps_id,
      Rails.configuration.x.scaife.projects,
      proj_id
    ))
      .with(
        headers: {
          'x_access_token' => x_access_token,
          #'Accept'=>'application/json',
          'Content-Type'=>'application/json',
        }
      ).to_return(
        status: code,
        body: body,
        headers: {}
      )

    api = Scaife::Api::Prioritization::UIToPrioritizationApi.new

    begin
      data, response_code, _headers =
        api.get_prioritization_with_http_info(ps_id, proj_id, x_access_token)
      if body.nil? or data.class == String
        response_body = data
      else
        response_body = data.to_json
      end
    rescue Scaife::Api::Prioritization::ApiError => e
      response_code = e.code
      response_body = e.response_body
    end

    assert_equal code, response_code
    body.nil? ? assert_nil(response_body) : assert_equal(body, response_body)
  end

  def stub_and_test_delete_prioritization(x_access_token,
          proj_id, ps_id, body, code)
    stub_request(:delete, File.join(
      Rails.configuration.x.scaife.prioritization_module_url,
      Rails.configuration.x.scaife.get_priority_scheme,
      ps_id,
      Rails.configuration.x.scaife.projects,
      proj_id
    ))
      .with(
        headers: {
          'x_access_token' => x_access_token,
          #'Accept'=>'application/json',
          #'Accept'=>'*/*',
          'Content-Type'=>'application/json',
        }
      ).to_return(
        status: code,
        body: body,
        headers: {}
      )

    api = Scaife::Api::Prioritization::UIToPrioritizationApi.new

    begin
      data, response_code, _headers =
        api.delete_prioritization_with_http_info(ps_id, proj_id,
                x_access_token)
      if body.nil? or data.class == String
        response_body = data
      else
        response_body = data.to_json
      end
    rescue Scaife::Api::Prioritization::ApiError => e
      response_code = e.code
      response_body = e.response_body
    end

    assert_equal code, response_code
    body.nil? ? assert_nil(response_body) : assert_equal(body, response_body)
  end

  def stub_and_test_list_classifiers(x_access_token, code)
    stub_request(:get, File.join(
      Rails.configuration.x.scaife.statistics_module_url,
      Rails.configuration.x.scaife.list_classifiers
    ))
      .with(
        headers: {
          'x_access_token' => x_access_token,
          'Accept'=>'application/json',
          'Content-Type'=>'application/json',
        }
      ).to_return(
        status: code,
        headers: {}
      )

    api = Scaife::Api::Statistics::UIToStatsApi.new

    begin
      data, response_code, _headers =
        api.list_classifiers_with_http_info(x_access_token)
      #if body.nil? or data.class == String
      #  response_body = data
      #else
      #  response_body = data.to_json
      #end
    rescue Scaife::Api::Statistics::ApiError => e
      response_code = e.code
      #response_body = e.response_body
    end

    assert_equal code, response_code
    #assert_equal body, response_body
  end


  def stub_and_test_list_projects(x_access_token, code)
    stub_request(:get, File.join(
      Rails.configuration.x.scaife.datahub_module_url,
      Rails.configuration.x.scaife.list_projects
    ))
      .with(
        headers: {
          'x_access_token' => x_access_token,
          'Accept'=>'application/json',
          'Content-Type'=>'application/json',
        }
      ).to_return(
        status: code,
        headers: {}
      )

    api = Scaife::Api::Datahub::DataHubServerApi.new

    begin
      data, response_code, _headers =
        api.list_projects_with_http_info(x_access_token)
      response_body = data.to_json
    rescue Scaife::Api::Datahub::ApiError => e
      response_code = e.code
      response_body = e.response_body
    end

    assert_equal code, response_code
    #assert_equal body, response_body
  end


  def stub_and_test_list_packages(x_access_token, code)
    stub_request(:get, File.join(
      Rails.configuration.x.scaife.datahub_module_url,
      Rails.configuration.x.scaife.list_packages
    ))
      .with(
        headers: {
          'x_access_token' => x_access_token,
          'Accept'=>'application/json',
          'Content-Type'=>'application/json',
        }
      ).to_return(
        status: code,
        headers: {}
      )

    api = Scaife::Api::Datahub::DataHubServerApi.new

    begin
      data, response_code, _headers =
        api.list_packages_with_http_info(x_access_token)
      response_body = data.to_json
    rescue Scaife::Api::Datahub::ApiError => e
      response_code = e.code
      response_body = e.response_body
    end

    assert_equal code, response_code
    #assert_equal body, response_body
  end


  def stub_and_test_list_languages(x_access_token, body, code)
    stub_request(:get, File.join(
      Rails.configuration.x.scaife.datahub_module_url,
      Rails.configuration.x.scaife.list_languages
    ))
      .with(
        headers: {
          'x_access_token' => x_access_token,
          'Accept'=>'application/json',
          'Content-Type'=>'application/json',
        }
      ).to_return(
        status: code,
        body: body,
        headers: {}
      )

    api = Scaife::Api::Datahub::DataHubServerApi.new

    begin
      data, response_code, _headers =
        api.list_languages_with_http_info(x_access_token)
      response_body = data.to_json
    rescue Scaife::Api::Datahub::ApiError => e
      response_code = e.code
      response_body = e.response_body
    end

    assert_equal code, response_code
    assert_equal body, response_body
  end

  def stub_and_test_create_language(x_access_token, l_name, l_version, body, code)
    stub_request(:post, File.join(
      Rails.configuration.x.scaife.datahub_module_url,
      Rails.configuration.x.scaife.create_language
    ))
      .with(
        body: {
          language: l_name,
          version: l_version
        }.to_json,
        headers: {
          'x_access_token' => x_access_token,
          'Accept'=>'application/json',
          'Content-Type'=>'application/json',
        }
      ).to_return(
        status: code,
        body: body,
        headers: {}
      )

    api = Scaife::Api::Datahub::UIToDataHubApi.new

    begin
      request_data = Scaife::Api::Datahub::LanguageMetadata.new(
        language: l_name,
        version: l_version
      )
      data, response_code, _headers =
        api.create_language_with_http_info(x_access_token, request_data)
      response_body = data.to_json
    rescue Scaife::Api::Datahub::ApiError => e
      response_code = e.code
      response_body = e.response_body
    end

    assert_equal code, response_code
    assert_equal body, response_body
  end

  def stub_and_test_list_taxonomies(x_access_token, body, code)
    stub_request(:get, File.join(
      Rails.configuration.x.scaife.datahub_module_url,
      Rails.configuration.x.scaife.list_taxonomies
    ))
      .with(
        headers: {
          'x_access_token' => x_access_token,
          'Accept'=>'application/json',
          'Content-Type'=>'application/json',
        }
      ).to_return(
        status: code,
        headers: {}
      )

    api = Scaife::Api::Datahub::DataHubServerApi.new

    begin
      data, response_code, _headers =
        api.list_taxonomies_with_http_info(x_access_token)
      response_body = data.to_json
    rescue Scaife::Api::Datahub::ApiError => e
      response_code = e.code
      response_body = e.response_body
    end

    assert_equal code, response_code
    #assert_equal body, response_body
  end

  def stub_and_test_create_taxonomy(x_access_token, t_name, t_version, descript, conditions, author_source, body, code)
    stub_request(:post, File.join(
      Rails.configuration.x.scaife.datahub_module_url,
      Rails.configuration.x.scaife.create_taxonomy
    ))
      .with(
        body: {
          taxonomy_name: t_name,
          taxonomy_version: t_version,
          description: descript,
          author_source: author_source,
          conditions: conditions
        }.to_json,
        headers: {
          'x_access_token' => x_access_token,
          'Accept'=>'application/json',
          'Content-Type'=>'application/json',
        }
      ).to_return(
        status: code,
        body: body,
        headers: {}
      )

    api = Scaife::Api::Datahub::UIToDataHubApi.new

    begin
      request_data = Scaife::Api::Datahub::TaxonomyMetadata.new(
        taxonomy_name: t_name,
        taxonomy_version: t_version,
        description: descript,
        author_source: author_source,
        conditions: conditions
      )
      data, response_code, _headers =
        api.create_taxonomy_with_http_info(x_access_token, request_data)
      response_body = data.to_json
    rescue Scaife::Api::Datahub::ApiError => e
      response_code = e.code
      response_body = e.response_body
    end

    assert_equal code, response_code
    assert_equal body, response_body
  end

  def stub_and_test_edit_taxonomy(x_access_token, t_id, conditions, body, code)
    stub_request(:put, File.join(
      Rails.configuration.x.scaife.datahub_module_url,
      Rails.configuration.x.scaife.edit_taxonomy,
      t_id
    ))
      .with(
        body: {
          conditions: conditions,
        }.to_json,
        headers: {
          'x_access_token' => x_access_token,
          'Accept'=>'application/json',
          'Content-Type'=>'application/json',
        }
      ).to_return(
        status: code,
        body: body,
        headers: {}
      )

    api = Scaife::Api::Datahub::UIToDataHubApi.new

    begin
      request_data = Scaife::Api::Datahub::EditTaxonomy.new(
        conditions: conditions,
      )
      data, response_code, _headers =
        api.edit_taxonomy_with_http_info(x_access_token, t_id, request_data)
      response_body = data.to_json
    rescue Scaife::Api::Datahub::ApiError => e
      response_code = e.code
      response_body = e.response_body
    end

    assert_equal code, response_code
    assert_equal body, response_body
  end

  def stub_and_test_list_tools(x_access_token, body, code)
    stub_request(:get, File.join(
      Rails.configuration.x.scaife.datahub_module_url,
      Rails.configuration.x.scaife.list_tools
    ))
      .with(
        headers: {
          'x_access_token' => x_access_token,
          'Accept'=>'application/json',
          'Content-Type'=>'application/json',
        }
      ).to_return(
        status: code,
        body: body,
        headers: {}
      )

    api = Scaife::Api::Datahub::DataHubServerApi.new

    begin
      data, response_code, _headers =
        api.list_tools_with_http_info(x_access_token)
      response_body = data.to_json
    rescue Scaife::Api::Datahub::ApiError => e
      response_code = e.code
      response_body = e.response_body
    end

    assert_equal code, response_code
    assert_equal body, response_body
  end


  def stub_and_test_upload_tool(x_access_token,
      t_name, t_version, category, platforms, code_language_ids,
      checker_mappings, checker_names, code_metrics_headers, author_source,
      body, code)
    stub_request(:post, File.join(
      Rails.configuration.x.scaife.datahub_module_url,
      Rails.configuration.x.scaife.upload_tool
    ))
      .with(
        body: {
          tool_name: t_name,
          tool_version: t_version,
          language_platforms: platforms,
          code_language_ids: code_language_ids,
          checker_mappings: checker_mappings,
          checkers: checker_names,
          code_metrics_headers: code_metrics_headers,
          author_source: author_source,
          category: category,
        }.to_json,
        headers: {
          'x_access_token' => x_access_token,
          'Accept'=>'application/json',
          'Content-Type'=>'application/json',
        }
      ).to_return(
        status: code,
        body: body,
        headers: {}
      )

    api = Scaife::Api::Datahub::UIToDataHubApi.new

    begin
      request_data = Scaife::Api::Datahub::ToolMetadata.new(
        tool_name: t_name,
        tool_version: t_version,
        language_platforms: platforms,
        code_language_ids: code_language_ids,
        checker_mappings: checker_mappings,
        checkers: checker_names,
        code_metrics_headers: code_metrics_headers,
        author_source: author_source,
        category: category
      )
      data, response_code, _headers =
        api.upload_tool_with_http_info(x_access_token, request_data)
      response_body = data.to_json
    rescue Scaife::Api::Datahub::ApiError => e
      response_code = e.code
      response_body = e.response_body
    end

    assert_equal code, response_code
    assert_equal body, response_body
  end


  def stub_and_test_get_tool_data(x_access_token, tool_id, code)
    stub_request(:get, File.join(
                  Rails.configuration.x.scaife.datahub_module_url,
            Rails.configuration.x.scaife.get_tool_data,
                        tool_id
    ))
      .with(
        headers: {
          'x_access_token' => x_access_token,
          'Accept'=>'application/json',
          'Content-Type'=>'application/json',
        }
      ).to_return(
        status: code,
        headers: {}
      )

    api = Scaife::Api::Datahub::DataHubServerApi.new

    begin
      data, response_code, _headers =
        api.get_tool_data_with_http_info(x_access_token, tool_id)
      response_body = data.to_json
    rescue Scaife::Api::Datahub::ApiError => e
      response_code = e.code
      response_body = e.response_body
    end

    assert_equal code, response_code
    #assert_equal body, response_body
  end


  def stub_and_test_edit_tool(x_access_token, tool_id, cm_file_path, body, code)
    stub_request(:put, File.join(
      Rails.configuration.x.scaife.datahub_module_url,
      Rails.configuration.x.scaife.edit_tool,
      tool_id
    ))
      .with(
        body: {
          multipart: true,
          checker_mapping_csv: File.open(cm_file_path, "r")
        },
        headers: {
          'x_access_token' => x_access_token
        }
      ).to_return(
        status: code,
        body: body,
        headers: {}
      )

    api = Scaife::Api::Datahub::UIToDataHubApi.new

    begin
      data, response_code, _headers =
        api.edit_tool_with_http_info(x_access_token, cm_file_path)
      response_body = data.to_json
    rescue Scaife::Api::Datahub::ApiError => e
      response_code = e.code
      response_body = e.response_body
    end

    assert_equal code, response_code
    assert_equal body, response_body
  end


  def stub_and_test_create_project(x_access_token, p_name, p_descript, author_src, package_id, m_alerts, taxonomy_ids, body, code)
    stub_request(:post, File.join(
      Rails.configuration.x.scaife.datahub_module_url,
      Rails.configuration.x.scaife.create_project
    ))
      .with(
        body: {
          project_name: p_name,
          project_description: p_descript,
          author_source: author_src,
          package_id: package_id,
          #meta_alerts: m_alerts,
          taxonomy_ids: taxonomy_ids
        },
        headers: {
          'x_access_token' => x_access_token,
        }
      ).to_return(
        status: code,
        body: body,
        headers: {}
      )

    api = Scaife::Api::Datahub::UIToDataHubApi.new

    begin
      request_data = Scaife::Api::Datahub::ProjectMetadata.new(
        project_name: p_name,
        project_description: p_descript,
        author_source: author_src,
        package_id: package_id,
        meta_alerts: m_alerts,
        taxonomy_ids: taxonomy_ids
      )
      data, response_code, _headers =
        api.create_project_with_http_info(x_access_token, request_data)
      response_body = data.to_json
    rescue Scaife::Api::Datahub::ApiError => e
      response_code = e.code
      response_body = e.response_body
    end

    assert_equal code, response_code
    assert_equal body, response_body
  end


  def stub_and_test_create_package(x_access_token, p_name, p_descript, author_src, lang_ids, code_src_url, src_file_url, src_func_url, ts_id, alerts, t_ids, body, code)
    stub_request(:post, File.join(
      Rails.configuration.x.scaife.datahub_module_url,
      Rails.configuration.x.scaife.create_package
    ))
      .with(
        body: {
          package_name: p_name,
          package_description: p_descript,
          author_source: author_src,
          code_language_ids: lang_ids,
          code_source_url: code_src_url,
          source_file_url: src_file_url,
          source_function_url: src_func_url,
          test_suite_id: ts_id,
          alerts: alerts,
          tool_ids: t_ids
        },
        headers: {
          'x_access_token' => x_access_token
        }
      ).to_return(
        status: code,
        body: body,
        headers: {}
      )

    api = Scaife::Api::Datahub::UIToDataHubApi.new

    begin
      request_data = Scaife::Api::Datahub::PackageMetadata.new(
        package_name: p_name,
        package_description: p_descript,
        author_source: author_src,
        code_language_ids: lang_ids,
        code_source_url: code_src_url,
        source_file_url: src_file_url,
        source_function_url: src_func_url,
        test_suite_id: ts_id,
        alerts: alerts,
        tool_ids: t_ids
      )
      data, response_code, _headers =
        api.create_package_with_http_info(x_access_token, request_data)
      response_body = data.to_json
    rescue Scaife::Api::Datahub::ApiError => e
      response_code = e.code
      response_body = e.response_body
    end

    assert_equal code, response_code
    assert_equal body, response_body
  end


  def stub_and_test_create_test_suite(x_access_token, test_suite_name, test_suite_version, test_suite_type, manifest_urls, use_license_file_url, author_source, code_languages, body, code)
    stub_request(:post, File.join(
      Rails.configuration.x.scaife.datahub_module_url,
      Rails.configuration.x.scaife.test_suites
    ))
      .with(
        body: {
          test_suite_name: test_suite_name,
          test_suite_version: test_suite_version,
          test_suite_type: test_suite_type,
          manifest_urls: manifest_urls,
          use_license_file_url: use_license_file_url,
          author_source: author_source,
          code_languages: code_languages
        },
        headers: {
          'x_access_token' => x_access_token
        }
      ).to_return(
        status: code,
        body: body,
        headers: {}
      )

    api = Scaife::Api::Datahub::UIToDataHubApi.new

    begin
      request_data = Scaife::Api::Datahub::TestSuiteMetadata.new(
        test_suite_name: test_suite_name,
        test_suite_version: test_suite_version,
        test_suite_type: test_suite_type,
        manifest_urls: manifest_urls,
        use_license_file_url: use_license_file_url,
        author_source: author_source,
        code_languages: code_languages
      )
      data, response_code, _headers =
        api.create_test_suite_with_http_info(x_access_token, request_data)
      response_body = data.to_json
    rescue Scaife::Api::Datahub::ApiError => e
      response_code = e.code
      response_body = e.response_body
    end

    assert_equal code, response_code
    assert_equal body, response_body
  end


=begin

  End SCAIFE method test helpers

=end

=begin

  Begin SCALe controller test helpers

=end
  def request_change_scaife_mode(mode)
    post "/change-scaife-mode", as: :json, params: {
      scaife_mode: mode
    },
    headers: basic_auth
  end

  def request_run_classifier(project_id, classifier_instance_name, mode)
    request_change_scaife_mode(mode)

    post "/alertConditions/#{project_id}/classifier/run", as: :json, params: {
      project_id: project_id,
      classifier_scheme_name: classifier_instance_name
    },
    headers: basic_auth

    assert_redirected_to "/projects/#{project_id}"
  end

  def request_getModals(mode, project_id, className, chosen, taxonomy = nil)
    request_change_scaife_mode(mode)

    params = {
      project_id: project_id,
      className: className,
      chosen: chosen
    }

    if not taxonomy.nil?
      params[:taxonomy] = taxonomy
    end

    get "/modals/open", as: :json, params: params, headers: basic_auth
  end

  def request_create_classifier(mode, classifier_instance_name, classifier_type, project_id, source_domain, adaptive_heuristic_name, adaptive_heuristic_parameters, use_pca, feature_selection_category, semantic_features, ahpo_name, ahpo_parameters, num_meta_alert_threshold, status)

    request_change_scaife_mode(mode)

    post "/modals/classifier/create", as: :json, params: {
      classifier_instance_name: classifier_instance_name,
      classifier_type: classifier_type,
      project_id: project_id,
      source_domain: source_domain,
      adaptive_heuristic_name: adaptive_heuristic_name,
      adaptive_heuristic_parameters: adaptive_heuristic_parameters,
      use_pca: use_pca,
      feature_selection_category: feature_selection_category,
      use_semantic_features: semantic_features,
      ahpo_name: ahpo_name,
      ahpo_parameters: ahpo_parameters,
      num_meta_alert_threshold: num_meta_alert_threshold,
    },
    headers: basic_auth

    assert_equal status, response.status
  end

  def request_view_classifier(mode, chosen)
    request_change_scaife_mode(mode)
    get '/modals/classifier/view', as: :json, params: {
      chosen: chosen
    },
    headers: basic_auth
  end

  def request_edit_classifier(mode, classifier_instance_name, classifier_type, project_id, source_domain, adaptive_heuristic_name, adaptive_heuristic_parameters, use_pca, feature_selection_category, semantic_features, ahpo_name, ahpo_parameters, num_meta_alert_threshold, status)
    request_change_scaife_mode(mode)
    post '/modals/classifier/edit', as: :json, params: {
      classifier_instance_name: classifier_instance_name,
      classifier_type: classifier_type,
      project_id: project_id,
      source_domain: source_domain,
      adaptive_heuristic_name: adaptive_heuristic_name,
      adaptive_heuristic_parameters: adaptive_heuristic_parameters,
      use_pca: use_pca,
      feature_selection_category: feature_selection_category,
      use_semantic_features: semantic_features,
      ahpo_name: ahpo_name,
      ahpo_parameters: ahpo_parameters,
      num_meta_alert_threshold: num_meta_alert_threshold,
    },
    headers: basic_auth

    assert_equal status, response.status
  end

  def request_delete_classifier(mode, project_id, classifier_instance_name, status)
    request_change_scaife_mode(mode)
    post '/modals/classifier/delete', as: :json, params: {
      project_id: project_id,
      classifier_name: classifier_instance_name
    },
    headers: basic_auth

    assert_equal status, response.status
  end

  def request_upload_user_fields(mode, upload, status)
    request_change_scaife_mode(mode)
    post '/modals/userUpload', as: :json, params: {
      column_upload: upload
    },
    headers: basic_auth

    assert_equal status, response.status
  end

  def request_getPriorityModal(mode, priority_id, project_id)
     request_change_scaife_mode(mode)

     get "/priorities/#{priority_id}/projects/#{project_id}/show", headers: basic_auth
  end

  def request_run_priority(mode, project_id, p_name, formula, cols, accept)
    headers = basic_auth
    headers["Accept"] = accept

    request_change_scaife_mode(mode)
    post "/priorities/#{project_id}/run", as: :json, params: {
      project_id: project_id,
      name: p_name,
      formula: formula,
      columns: cols
    },
    headers: headers
  end

  def request_create_priority(mode, p_name, project_id, save_type,
          formula, cols, status)
    request_change_scaife_mode(mode)
    post "/priorities/#{project_id}/save", as: :json, params: {
      priority_name: p_name,
      project_id: project_id,
      formula: formula,
      columns: cols,
      save_type: save_type
    },
    headers: basic_auth

    assert_equal status, response.status
  end

  def request_edit_priority(mode, p_name, priority_id, project_id, save_type,
          formula, cols, status)
    request_change_scaife_mode(mode)
    post "/priorities/#{project_id}/edit", as: :json, params: {
      priority_name: p_name,
      priority_id: priority_id,
      project_id: project_id,
      save_type: save_type,
      formula: formula,
      columns: cols
    },
    headers: basic_auth

    assert_equal status, response.status
  end

  def request_delete_priority(mode, p_name, project_id, priority_id, status)
    request_change_scaife_mode(mode)
    post '/priorities/delete', as: :json, params: {
      priority_name: p_name,
      project_id: project_id,
      priority_id: priority_id
    },
    headers: basic_auth

    assert_equal status, response.status
  end

=begin

  GET /projects/:project_id

  params:
    project_id (int) - project_id
    accept (str) - "Accept header"
    args (Hash) - Hash containing request params

=end
  def request_alert_controller_index(project_id, accept, args)
    headers = basic_auth
    headers["Accept"] = accept
    get "/projects/#{project_id}", as: :json, params: args,
    headers: headers,
    xhr: true

    assert_response :success
  end

  def request_fused_unfused_view(project_id, view)
    if view == "fused"
      get "/projects/#{project_id}/fused", headers: basic_auth
      assert_redirected_to "/projects/#{project_id}"
    elsif view == "unfused"
      get "/projects/#{project_id}/unfused", headers: basic_auth
      assert_response :success
    end

  end

=begin
  POST /alertConditions/update

  optional params:
    args (Hash) - optional params
      select_all_checkbox (bool) - only exists if checkbox is checked
      selected_alerts ([int]) - array of selected ids (display id if unfused
                                view, meta_alert_id if fused view)
=end
  def request_mass_update(project_id, view, verdict, flag, ignored, dead, ienv,
    dc, args)
    request_fused_unfused_view(project_id, view)
    params = {
      mass_update_verdict: verdict,
      flag: flag,
      ignored: ignored,
      dead: dead,
      inapplicable_environment: ienv,
      mass_update_dc: dc
    }

    if args[:select_all_checkbox]
      params[:select_all_checkbox] = args[:select_all_checkbox]
    elsif args[:selectedAlertConditions]
      params[:selectedAlertConditions] = args[:selectedAlertConditions]
    end

    post '/alertConditions/update', params: params,
    headers: basic_auth

    assert_response :success
  end

  def deserialize_bool(v)
    if v == "f"
      return false
    elsif v == "t"
      return true
    end
  end

  def verify_mass_update(project_id, view, verdict, flag, ignored, dead, ienv,
    dc, expected_verdict, expected_flag, expected_ignored, expected_dead,
    expected_ienv, expected_dc, mass_update_args, accept, checker, index_args)

    request_alert_controller_index(project_id, accept, index_args)
    expected_displayed_ACs = Display.where(project_id: project_id)
      .where(checker: checker)
    expected_m_ids = expected_displayed_ACs.distinct.pluck(:meta_alert_id)
    not_updated_AC = displays(:massupdate_display_10)
    not_updated_verdict = not_updated_AC.verdict
    not_updated_flag = not_updated_AC.flag
    not_updated_ignored = not_updated_AC.ignored
    not_updated_dead = not_updated_AC.dead
    not_updated_ienv = not_updated_AC.inapplicable_environment
    not_updated_dc = not_updated_AC.dangerous_construct
    other_proj_AC = displays(:massupdate_display_11)
    other_proj_verdict = other_proj_AC.verdict
    other_proj_flag = other_proj_AC.flag
    other_proj_ignored = other_proj_AC.ignored
    other_proj_dead = other_proj_AC.dead
    other_proj_ienv = other_proj_AC.inapplicable_environment
    other_proj_dc = other_proj_AC.dangerous_construct

    # correct alertConditions displayed via filter
    assert_equal expected_displayed_ACs.count, $displayedAlertConditions.count

    # mass update with select_all checkbox checked
    request_mass_update(project_id, view, verdict, flag, ignored, dead, ienv,
    dc, mass_update_args)

    # displayed alertsConditions updated
    #can't use this until Determinations table name is corrected to singular
    #dets = Determination.where(project: project_id)
    #  .where(meta_alert_id: expected_m_ids)
    if view == "fused"
      array = expected_m_ids.flatten.join(',')
      sql = "SELECT project_id, meta_alert_id, max(time), verdict, flag,"\
        " ignored, dead, inapplicable_environment, dangerous_construct"\
        " FROM determinations WHERE project_id = #{project_id}"\
        " AND meta_alert_id IN (#{array});"
      ds = ActiveRecord::Base.connection.execute(sql)

      ds.each do |d|
        if mass_update_args[:select_all_checkbox]
          assert_equal expected_verdict, d["verdict"]
          assert_equal expected_flag, d["flag"]
          assert_equal expected_ignored, d["ignored"]
          assert_equal expected_dead, d["dead"]
          assert_equal expected_ienv, d["inapplicable_environment"]
          assert_equal expected_dc.to_s, d["dangerous_construct"]
        elsif mass_update_args[:selectedAlertConditions].include? d["id"]
          assert_equal expected_verdict, d["verdict"]
          assert_equal expected_flag, d["flag"]
          assert_equal expected_ignored, d["ignored"]
          assert_equal expected_dead, d["dead"]
          assert_equal expected_ienv, d["inapplicable_environment"]
          assert_equal expected_dc, d["dangerous_construct"]
        else
          assert_equal not_updated_verdict, d["verdict"]
          d["flag"] = deserialize_bool(d["flag"])
          d["ignored"] = deserialize_bool(d["ignored"])
          d["dead"] = deserialize_bool(d["dead"])
          d["inapplicable_environment"] = deserialize_bool(d["inapplicable_environment"])

          assert_equal not_updated_flag, d["flag"]
          assert_equal not_updated_ignored, d["ignored"]
          assert_equal not_updated_dead, d["dead"]
          assert_equal not_updated_ienv, d["inapplicable_environment"]
          assert_equal not_updated_dc.to_s, d["dangerous_construct"]
        end
      end

    elsif view == "unfused"
      alertConds = Display.where(project_id: project_id)
        .where(checker: checker)

      alertConds.each do |d|
        if mass_update_args[:selectedAlertConditions].include? d.id
          assert_equal expected_verdict, d.verdict
          assert_equal expected_flag, d.flag
          assert_equal expected_ignored, d.ignored
          assert_equal expected_dead, d.dead
          assert_equal expected_ienv, d.inapplicable_environment
          assert_equal expected_dc, d.dangerous_construct
        else
          assert_equal not_updated_verdict, d.verdict
          assert_equal not_updated_flag, d.flag
          assert_equal not_updated_ignored, d.ignored
          assert_equal not_updated_dead, d.dead
          assert_equal not_updated_ienv, d.inapplicable_environment
        end
      end

    end

    # displays not displayed not updated
    assert_equal not_updated_verdict, displays(:massupdate_display_10).verdict
    assert_equal not_updated_flag, displays(:massupdate_display_10).flag
    assert_equal not_updated_ignored, displays(:massupdate_display_10).ignored
    assert_equal not_updated_dead, displays(:massupdate_display_10).dead
    assert_equal not_updated_ienv, displays(:massupdate_display_10)
      .inapplicable_environment
    assert_equal not_updated_dc, displays(:massupdate_display_10)
      .dangerous_construct

    # displays in other projects not updated
    assert_equal other_proj_verdict, other_proj_AC.verdict
    assert_equal other_proj_flag, other_proj_AC.flag
    assert_equal other_proj_ignored, other_proj_AC.ignored
    assert_equal other_proj_dead, other_proj_AC.dead
    assert_equal other_proj_ienv, other_proj_AC.inapplicable_environment
    assert_equal other_proj_dc, other_proj_AC.dangerous_construct
  end

  def stub_and_test_submitRegister(first, last, org, user, pass, reg_code,
        login_code, reg_body, login_body, expected_login_token,
        expected_scaife_mode)

    with_offline_testing() do

      headers = basic_auth
      headers["Accept"] = "text/javascript"
  
      stub_request(:post, File.join(
        Rails.configuration.x.scaife.registration_module_url,
        Rails.configuration.x.scaife.register
      ))
        .with(
          body: {
            first_name: first,
            last_name: last,
            organization_name: org,
            username: user,
            password: pass
          }.to_json,
          headers: {
            # accept successful plain text message
            'Accept'=>'application/json',
            'Content-Type'=>'application/json',
          }
        ).to_return(
          status: reg_code,
          body: reg_body,
          headers: {}
        )
  
      stub_request(:post, File.join(
        Rails.configuration.x.scaife.registration_module_url,
        Rails.configuration.x.scaife.login
      ))
        .with(
          body: {
            username: user,
            password: pass
          }.to_json,
          headers: {
            #'Accept'=>'application/json',
            'Content-Type'=>'application/json',
          }
        ).to_return(
          status: login_code,
          body: login_body,
          headers: {}
        )
  
      post '/scaife-registration/register-submit', as: :json,
      params: {
        firstname_field: first,
        lastname_field: last,
        org_field: org,
        user_field: user,
        password_field: pass
      },
      headers: headers,
      xhr: true
  
      assert_response :success
      if reg_code.nil?
        assert_nil @controller.instance_variable_get(:@scaife_status_code)
      else
        assert_equal reg_code,
          @controller.instance_variable_get(:@scaife_status_code)
      end
  
      if login_code.nil?
        assert_nil @controller.instance_variable_get(:@scaife_login_status_code)
      else
        assert_equal login_code,
          @controller.instance_variable_get(:@scaife_login_status_code)
      end
  
      if expected_login_token.nil?
        assert_nil request.session[:login_token]
      else
        assert_equal expected_login_token, request.session[:login_token]
      end
  
      if expected_scaife_mode.nil?
        assert_nil request.session[:scaife_mode]
      else
        assert_equal expected_scaife_mode, request.session[:scaife_mode]
      end

    end

  end

  def stub_and_test_submitLogin(user, pass, code, body, expected_login_token,
        expected_scaife_mode)

    with_offline_testing() do

      headers = basic_auth
      headers["Accept"] = "text/javascript"
  
      stub_request(:post, File.join(
        Rails.configuration.x.scaife.registration_module_url,
        Rails.configuration.x.scaife.login
      ))
        .with(
          body: {
            username: user,
            password: pass
          }.to_json,
          headers: {
            'Accept'=>'application/json',
            'Content-Type'=>'application/json',
          }
        ).to_return(
          status: code,
          body: body,
          headers: {}
        )
  
      post '/scaife-registration/login-submit', as: :json,
      params: {
        user_field: user,
        password_field: pass
      },
      headers: headers,
      xhr: true
  
      assert_response :success
  
      if code.nil?
        assert_nil code
      else
        assert_equal code,
          @controller.instance_variable_get(:@scaife_status_code)
      end
  
      if expected_login_token.nil?
        assert_nil request.session[:login_token]
      else
        assert_equal expected_login_token, request.session[:login_token]
      end
  
      if expected_scaife_mode.nil?
        assert_nil request.session[:scaife_mode]
      else
        assert_equal expected_scaife_mode, request.session[:scaife_mode]
      end

    end

  end

=begin

  End SCALe controller test helpers

=end
end
