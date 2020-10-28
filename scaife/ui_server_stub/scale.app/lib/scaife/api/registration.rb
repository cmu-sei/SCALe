# <legal>
# SCALe version r.6.2.2.2.A
# 
# Copyright 2020 Carnegie Mellon University.
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

module Scaife
module Api
module Registration

=begin

API calls to SCAIFE Registration module

=end

=begin
  Register a user for SCAIFE

  params:
    first (string) - first name
    last (string) - last name
    org (string) - organization name
    user (string) - username
    pass (string) - password

  returns:
    r (RestClient::Response) - the response object
    Throws exception if unable to connect to SCAIFE
=end
  def SCAIFE_register(first, last, org, user, pass)
    begin
      r = RestClient::Request.execute(
        method: :post,
        url: File.join(
          Rails.configuration.x.scaife.registration_module_url,
          Rails.configuration.x.scaife.register
        ),
        payload: {
          first_name: first,
          last_name: last,
          organization_name: org,
          username: user,
          password: pass
        }.to_json,
        headers: {
          content_type: :json,
          accept: :json
        }
      )
    rescue RestClient::ExceptionWithResponse => e
      r = e.response
    end

    return r
  end

=begin

  Login to SCAIFE

  params:
    user (string) - username
    pass (string) - password

  returns:
    r (RestClient::Response) - the response object
    Throws exception if unable to connect to SCAIFE
=end
  def SCAIFE_login(user, pass)
    begin
      r = RestClient::Request.execute(
        method: :post,
        url: File.join(
          Rails.configuration.x.scaife.registration_module_url,
          Rails.configuration.x.scaife.login
        ),
        payload: {
          username: user,
          password: pass
        }.to_json,
        headers: {
          content_type: :json,
          accept: :json
        }
      )
    rescue RestClient::ExceptionWithResponse => e
      r = e.response
    end

    return r
  end

=begin

  Request access token for a particular server module

  params:
    server (string) - server name
      expected values:
        "datahub"
        "prioritization"
        "statistics"
    login_token (string) - x_access_token from SCAIFE_login()

  returns:
    r (RestClient::Response) - the response object
    Throws exception if unable to connect to SCAIFE
=end
  def SCAIFE_get_access_token (server_name, login_token)
    begin
      r = RestClient::Request.execute(
        method: :get,
        url: File.join(
          Rails.configuration.x.scaife.registration_module_url,
          Rails.configuration.x.scaife.get_access_token,
          server_name
        ),
        headers: {
          x_access_token: login_token,
          content_type: :json,
          accept: :json
        }
      )

    rescue RestClient::ExceptionWithResponse => e
      r = e.response
    end

    return r
  end

=begin

  Logout of SCAIFE

  returns:
    r (RestClient::Response) - the response object
    Throws exception if unable to connect to SCAIFE
=end

  def SCAIFE_logout(login_token, request_token)
    begin
      r = RestClient::Request.execute(
        method: :post,
        url: File.join(
          Rails.configuration.x.scaife.registration_module_url,
          Rails.configuration.x.scaife.logout
        ),
        headers: {
          x_access_token: login_token,
          x_request_token: request_token,
          content_type: :json,
          accept: :json
        }
      )
    rescue RestClient::ExceptionWithResponse => e
      r = e.response
    end

    return r
  end

end
end
end
