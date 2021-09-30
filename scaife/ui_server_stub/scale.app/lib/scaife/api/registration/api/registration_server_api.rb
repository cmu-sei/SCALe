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

  class RegistrationServerApi
    attr_accessor :api_client

    def initialize(api_client = ApiClient.default)
      @api_client = api_client
    end
    # Authenticate the access token for the servers
    # @param server_name [String] Name of the server to verify access to, expected values [statistics, datahub, prioritization]
    # @param x_access_token [String] Access token verifying user
    # @param [Hash] opts the optional parameters
    # @return [nil]
    def authenticate_server_access(server_name, x_access_token, opts = {})
      authenticate_server_access_with_http_info(server_name, x_access_token, opts)
      nil
    end

    # Authenticate the access token for the servers
    # @param server_name [String] Name of the server to verify access to, expected values [statistics, datahub, prioritization]
    # @param x_access_token [String] Access token verifying user
    # @param [Hash] opts the optional parameters
    # @return [Array<(nil, Integer, Hash)>] nil, response status code and response headers
    def authenticate_server_access_with_http_info(server_name, x_access_token, opts = {})
      if @api_client.config.debugging
        @api_client.config.logger.debug 'Calling API: RegistrationServerApi.authenticate_server_access ...'
      end
      # verify the required parameter 'server_name' is set
      if @api_client.config.client_side_validation && server_name.nil?
        fail ArgumentError, "Missing the required parameter 'server_name' when calling RegistrationServerApi.authenticate_server_access"
      end
      # verify the required parameter 'x_access_token' is set
      if @api_client.config.client_side_validation && x_access_token.nil?
        fail ArgumentError, "Missing the required parameter 'x_access_token' when calling RegistrationServerApi.authenticate_server_access"
      end
      # resource path
      local_var_path = '/authenticate/{server_name}'.sub('{' + 'server_name' + '}', CGI.escape(server_name.to_s))

      # query parameters
      query_params = opts[:query_params] || {}

      # header parameters
      header_params = opts[:header_params] || {}
      header_params[:'x_access_token'] = x_access_token

      # form parameters
      form_params = opts[:form_params] || {}

      # http body (model)
      post_body = opts[:debug_body]

      # return_type
      return_type = opts[:debug_return_type]

      # auth_names
      auth_names = opts[:debug_auth_names] || []

      new_options = opts.merge(
        :operation => :"RegistrationServerApi.authenticate_server_access",
        :header_params => header_params,
        :query_params => query_params,
        :form_params => form_params,
        :body => post_body,
        :auth_names => auth_names,
        :return_type => return_type
      )

      data, status_code, headers = @api_client.call_api(:GET, local_var_path, new_options)
      if @api_client.config.debugging
        @api_client.config.logger.debug "API called: RegistrationServerApi#authenticate_server_access\nData: #{data.inspect}\nStatus code: #{status_code}\nHeaders: #{headers}"
      end
      return data, status_code, headers
    end

    # Provides Server Status
    # @param [Hash] opts the optional parameters
    # @return [nil]
    def get_status(opts = {})
      get_status_with_http_info(opts)
      nil
    end

    # Provides Server Status
    # @param [Hash] opts the optional parameters
    # @return [Array<(nil, Integer, Hash)>] nil, response status code and response headers
    def get_status_with_http_info(opts = {})
      if @api_client.config.debugging
        @api_client.config.logger.debug 'Calling API: RegistrationServerApi.get_status ...'
      end
      # resource path
      local_var_path = '/status'

      # query parameters
      query_params = opts[:query_params] || {}

      # header parameters
      header_params = opts[:header_params] || {}

      # form parameters
      form_params = opts[:form_params] || {}

      # http body (model)
      post_body = opts[:debug_body]

      # return_type
      return_type = opts[:debug_return_type]

      # auth_names
      auth_names = opts[:debug_auth_names] || []

      new_options = opts.merge(
        :operation => :"RegistrationServerApi.get_status",
        :header_params => header_params,
        :query_params => query_params,
        :form_params => form_params,
        :body => post_body,
        :auth_names => auth_names,
        :return_type => return_type
      )

      data, status_code, headers = @api_client.call_api(:GET, local_var_path, new_options)
      if @api_client.config.debugging
        @api_client.config.logger.debug "API called: RegistrationServerApi#get_status\nData: #{data.inspect}\nStatus code: #{status_code}\nHeaders: #{headers}"
      end
      return data, status_code, headers
    end
  end

end
end
end
