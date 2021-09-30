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

class ModalsController < ApplicationController

  def massUpdate
    respond_to do |format|
      format.html
      format.js
    end
  end

  def uploadUserFields #Save uploaded columns names
    case session[:scaife_mode]
    #TODO: implement SCAIFE functionality
    when "Connected", "Demo"
      file_contents = params[:column_upload]

      begin
        file_contents = JSON.parse(file_contents)
      rescue JSON::ParserError
        respond_to do |format|
          format.json { render json: "Bad Request", status: 400 }
        end
      end

      status = 200
      msg = ""

      begin
          success = UserUpload.createUserUpload(file_contents)
          if success
            msg = { status: "200", message: "Success" }
          else
            msg = { status: "400", message: "Bad Request" }
            status = 400
          end
        rescue ActiveRecord::RecordNotFound
          msg = { status: "500", message: "Internal Server Error" }
          status = 500
        rescue ActiveRecord::ActiveRecordError
          msg = { status: "500", message: "Internal Server Error" }
          status = 500
        rescue Exception
          raise
        ensure
          respond_to do |format|
            format.json { render json: msg, status: status }
          end
      end
    else
      # SCALe-only mode
      head 405
    end
  end


end
