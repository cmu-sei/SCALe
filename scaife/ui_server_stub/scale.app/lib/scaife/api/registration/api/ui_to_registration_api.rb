# Client code for the SCAIFE Registration and Login Module
#
# Generated by: https://openapi-generator.tech
# OpenAPI Generator version: 5.0.0
#
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

require 'cgi'

module Scaife
module Api
module Registration

  class UIToRegistrationApi
    attr_accessor :api_client

    def initialize(api_client = ApiClient.default)
      @api_client = api_client
    end
    # Get access token to use other servers
    # @param server_name [String] Name of the server to grant access to, expected values [statistics, datahub, prioritization]
    # @param x_access_token [String] Access token verifying user
    # @param [Hash] opts the optional parameters
    # @return [AccessToken]
    def get_server_access(server_name, x_access_token, opts = {})
      data, _status_code, _headers = get_server_access_with_http_info(server_name, x_access_token, opts)
      data
    end

    # Get access token to use other servers
    # @param server_name [String] Name of the server to grant access to, expected values [statistics, datahub, prioritization]
    # @param x_access_token [String] Access token verifying user
    # @param [Hash] opts the optional parameters
    # @return [Array<(AccessToken, Integer, Hash)>] AccessToken data, response status code and response headers
    def get_server_access_with_http_info(server_name, x_access_token, opts = {})
      if @api_client.config.debugging
        @api_client.config.logger.debug 'Calling API: UIToRegistrationApi.get_server_access ...'
      end
      # verify the required parameter 'server_name' is set
      if @api_client.config.client_side_validation && server_name.nil?
        fail ArgumentError, "Missing the required parameter 'server_name' when calling UIToRegistrationApi.get_server_access"
      end
      # verify the required parameter 'x_access_token' is set
      if @api_client.config.client_side_validation && x_access_token.nil?
        fail ArgumentError, "Missing the required parameter 'x_access_token' when calling UIToRegistrationApi.get_server_access"
      end
      # resource path
      local_var_path = File.join(
        Rails.configuration.x.scaife.get_access_token,
        CGI.escape(server_name.to_s)
      )

      # query parameters
      query_params = opts[:query_params] || {}

      # header parameters
      header_params = opts[:header_params] || {}
      # HTTP header 'Accept' (if needed)
      header_params['Accept'] = @api_client.select_header_accept(['application/json'])
      header_params[:'x_access_token'] = x_access_token

      # form parameters
      form_params = opts[:form_params] || {}

      # http body (model)
      post_body = opts[:debug_body]

      # return_type
      return_type = opts[:debug_return_type] || 'AccessToken'

      # auth_names
      auth_names = opts[:debug_auth_names] || []

      new_options = opts.merge(
        :operation => :"UIToRegistrationApi.get_server_access",
        :header_params => header_params,
        :query_params => query_params,
        :form_params => form_params,
        :body => post_body,
        :auth_names => auth_names,
        :return_type => return_type
      )

      data, status_code, headers = @api_client.call_api(:GET, local_var_path, new_options)
      if @api_client.config.debugging
        @api_client.config.logger.debug "API called: UIToRegistrationApi#get_server_access\nData: #{data.inspect}\nStatus code: #{status_code}\nHeaders: #{headers}"
      end
      return data, status_code, headers
    end

    # Login page; Authenticate to the SCAIFE system
    # @param login_credentials [LoginCredentials] Login credentials for the user.
    # @param [Hash] opts the optional parameters
    # @return [AccessToken]
    def login_user(login_credentials, opts = {})
      data, _status_code, _headers = login_user_with_http_info(login_credentials, opts)
      data
    end

    # Login page; Authenticate to the SCAIFE system
    # @param login_credentials [LoginCredentials] Login credentials for the user.
    # @param [Hash] opts the optional parameters
    # @return [Array<(AccessToken, Integer, Hash)>] AccessToken data, response status code and response headers
    def login_user_with_http_info(login_credentials, opts = {})
      if @api_client.config.debugging
        @api_client.config.logger.debug 'Calling API: UIToRegistrationApi.login_user ...'
      end
      # verify the required parameter 'login_credentials' is set
      if @api_client.config.client_side_validation && login_credentials.nil?
        fail ArgumentError, "Missing the required parameter 'login_credentials' when calling UIToRegistrationApi.login_user"
      end
      # resource path
      local_var_path = Rails.configuration.x.scaife.login

      # query parameters
      query_params = opts[:query_params] || {}

      # header parameters
      header_params = opts[:header_params] || {}
      # HTTP header 'Accept' (if needed)
      header_params['Accept'] = @api_client.select_header_accept(['application/json'])
      # HTTP header 'Content-Type'
      header_params['Content-Type'] = @api_client.select_header_content_type(['application/json'])

      # form parameters
      form_params = opts[:form_params] || {}

      # http body (model)
      post_body = opts[:debug_body] || @api_client.object_to_http_body(login_credentials)

      # return_type
      return_type = opts[:debug_return_type] || 'AccessToken'

      # auth_names
      auth_names = opts[:debug_auth_names] || []

      new_options = opts.merge(
        :operation => :"UIToRegistrationApi.login_user",
        :header_params => header_params,
        :query_params => query_params,
        :form_params => form_params,
        :body => post_body,
        :auth_names => auth_names,
        :return_type => return_type
      )

      data, status_code, headers = @api_client.call_api(:POST, local_var_path, new_options)
      if @api_client.config.debugging
        @api_client.config.logger.debug "API called: UIToRegistrationApi#login_user\nData: #{data.inspect}\nStatus code: #{status_code}\nHeaders: #{headers}"
      end
      return data, status_code, headers
    end

    # Logout of the SCAIFE system
    # @param x_access_token [String] Access token from login, verifying the user
    # @param [Hash] opts the optional parameters
    # @return [String]
    def logout_user(x_access_token, opts = {})
      data, _status_code, _headers = logout_user_with_http_info(x_access_token, opts)
      data
    end

    # Logout of the SCAIFE system
    # @param x_access_token [String] Access token from login, verifying the user
    # @param [Hash] opts the optional parameters
    # @return [Array<(String, Integer, Hash)>] String data, response status code and response headers
    def logout_user_with_http_info(x_access_token, opts = {})
      if @api_client.config.debugging
        @api_client.config.logger.debug 'Calling API: UIToRegistrationApi.logout_user ...'
      end
      # verify the required parameter 'x_access_token' is set
      if @api_client.config.client_side_validation && x_access_token.nil?
        fail ArgumentError, "Missing the required parameter 'x_access_token' when calling UIToRegistrationApi.logout_user"
      end
      # resource path
      local_var_path = Rails.configuration.x.scaife.logout

      # query parameters
      query_params = opts[:query_params] || {}

      # header parameters
      header_params = opts[:header_params] || {}
      # HTTP header 'Accept' (if needed)
      header_params['Accept'] = @api_client.select_header_accept(['application/json'])
      header_params[:'x_access_token'] = x_access_token

      # form parameters
      form_params = opts[:form_params] || {}

      # http body (model)
      post_body = opts[:debug_body]

      # return_type
      return_type = opts[:debug_return_type] || 'String'

      # auth_names
      auth_names = opts[:debug_auth_names] || []

      new_options = opts.merge(
        :operation => :"UIToRegistrationApi.logout_user",
        :header_params => header_params,
        :query_params => query_params,
        :form_params => form_params,
        :body => post_body,
        :auth_names => auth_names,
        :return_type => return_type
      )

      data, status_code, headers = @api_client.call_api(:POST, local_var_path, new_options)
      if @api_client.config.debugging
        @api_client.config.logger.debug "API called: UIToRegistrationApi#logout_user\nData: #{data.inspect}\nStatus code: #{status_code}\nHeaders: #{headers}"
      end
      return data, status_code, headers
    end

    # Registration page; Create new users in the SCAIFE system
    # @param user_information [UserInformation] User information
    # @param [Hash] opts the optional parameters
    # @return [String]
    def register_users(user_information, opts = {})
      data, _status_code, _headers = register_users_with_http_info(user_information, opts)
      data
    end

    # Registration page; Create new users in the SCAIFE system
    # @param user_information [UserInformation] User information
    # @param [Hash] opts the optional parameters
    # @return [Array<(String, Integer, Hash)>] String data, response status code and response headers
    def register_users_with_http_info(user_information, opts = {})
      if @api_client.config.debugging
        @api_client.config.logger.debug 'Calling API: UIToRegistrationApi.register_users ...'
      end
      # verify the required parameter 'user_information' is set
      if @api_client.config.client_side_validation && user_information.nil?
        fail ArgumentError, "Missing the required parameter 'user_information' when calling UIToRegistrationApi.register_users"
      end
      # resource path
      local_var_path = Rails.configuration.x.scaife.register

      # query parameters
      query_params = opts[:query_params] || {}

      # header parameters
      header_params = opts[:header_params] || {}
      # HTTP header 'Accept' (if needed)
      header_params['Accept'] = @api_client.select_header_accept(['application/json'])
      # HTTP header 'Content-Type'
      header_params['Content-Type'] = @api_client.select_header_content_type(['application/json'])

      # form parameters
      form_params = opts[:form_params] || {}

      # http body (model)
      post_body = opts[:debug_body] || @api_client.object_to_http_body(user_information)

      # return_type
      return_type = opts[:debug_return_type] || 'String'

      # auth_names
      auth_names = opts[:debug_auth_names] || []

      new_options = opts.merge(
        :operation => :"UIToRegistrationApi.register_users",
        :header_params => header_params,
        :query_params => query_params,
        :form_params => form_params,
        :body => post_body,
        :auth_names => auth_names,
        :return_type => return_type
      )

      data, status_code, headers = @api_client.call_api(:POST, local_var_path, new_options)
      if @api_client.config.debugging
        @api_client.config.logger.debug "API called: UIToRegistrationApi#register_users\nData: #{data.inspect}\nStatus code: #{status_code}\nHeaders: #{headers}"
      end
      return data, status_code, headers
    end
  end

end
end
end