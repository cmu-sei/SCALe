# Client code for the SCAIFE Datahub Module
#
# Generated by: https://openapi-generator.tech
# OpenAPI Generator version: 5.0.1
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
module Datahub

  class CIToDataHubApi
    attr_accessor :api_client

    def initialize(api_client = ApiClient.default)
      @api_client = api_client
    end
    # Submit static analysis results to SCAIFE
    # @param x_access_token [String] Token that contains information about the package
    # @param git_commit_hash [String] Git hash triggering the SCAIFE analysis
    # @param tool_id [String] Tool ID of tool matching the submitted output (eg. ID of cppcheck)
    # @param tool_output [File] Static analysis tool output
    # @param [Hash] opts the optional parameters
    # @return [CiResult]
    def ci_analyze(x_access_token, git_commit_hash, tool_id, tool_output, opts = {})
      data, _status_code, _headers = ci_analyze_with_http_info(x_access_token, git_commit_hash, tool_id, tool_output, opts)
      data
    end

    # Submit static analysis results to SCAIFE
    # @param x_access_token [String] Token that contains information about the package
    # @param git_commit_hash [String] Git hash triggering the SCAIFE analysis
    # @param tool_id [String] Tool ID of tool matching the submitted output (eg. ID of cppcheck)
    # @param tool_output [File] Static analysis tool output
    # @param [Hash] opts the optional parameters
    # @return [Array<(CiResult, Integer, Hash)>] CiResult data, response status code and response headers
    def ci_analyze_with_http_info(x_access_token, git_commit_hash, tool_id, tool_output, opts = {})
      if @api_client.config.debugging
        @api_client.config.logger.debug 'Calling API: CIToDataHubApi.ci_analyze ...'
      end
      # verify the required parameter 'x_access_token' is set
      if @api_client.config.client_side_validation && x_access_token.nil?
        fail ArgumentError, "Missing the required parameter 'x_access_token' when calling CIToDataHubApi.ci_analyze"
      end
      # verify the required parameter 'git_commit_hash' is set
      if @api_client.config.client_side_validation && git_commit_hash.nil?
        fail ArgumentError, "Missing the required parameter 'git_commit_hash' when calling CIToDataHubApi.ci_analyze"
      end
      # verify the required parameter 'tool_id' is set
      if @api_client.config.client_side_validation && tool_id.nil?
        fail ArgumentError, "Missing the required parameter 'tool_id' when calling CIToDataHubApi.ci_analyze"
      end
      # verify the required parameter 'tool_output' is set
      if @api_client.config.client_side_validation && tool_output.nil?
        fail ArgumentError, "Missing the required parameter 'tool_output' when calling CIToDataHubApi.ci_analyze"
      end
      # resource path
      local_var_path = '/analyze'

      # query parameters
      query_params = opts[:query_params] || {}

      # header parameters
      header_params = opts[:header_params] || {}
      # HTTP header 'Accept' (if needed)
      header_params['Accept'] = @api_client.select_header_accept(['application/json'])
      # HTTP header 'Content-Type'
      header_params['Content-Type'] = @api_client.select_header_content_type(['multipart/form-data'])
      header_params[:'x_access_token'] = x_access_token

      # form parameters
      form_params = opts[:form_params] || {}
      form_params['git_commit_hash'] = git_commit_hash
      form_params['tool_id'] = tool_id
      form_params['tool_output'] = tool_output

      # http body (model)
      post_body = opts[:debug_body]

      # return_type
      return_type = opts[:debug_return_type] || 'CiResult'

      # auth_names
      auth_names = opts[:debug_auth_names] || []

      new_options = opts.merge(
        :operation => :"CIToDataHubApi.ci_analyze",
        :header_params => header_params,
        :query_params => query_params,
        :form_params => form_params,
        :body => post_body,
        :auth_names => auth_names,
        :return_type => return_type
      )

      data, status_code, headers = @api_client.call_api(:POST, local_var_path, new_options)
      if @api_client.config.debugging
        @api_client.config.logger.debug "API called: CIToDataHubApi#ci_analyze\nData: #{data.inspect}\nStatus code: #{status_code}\nHeaders: #{headers}"
      end
      return data, status_code, headers
    end
  end

end
end
end