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

module TransferFile
  require 'uri'
  require 'open-uri'
  require 'rack/mime'

  def download_url_to(url, path)
    encoded_url = URI.encode(url)
    puts "download: #{url}"
    puts "destination: #{path}"
    start_time = Time.now
    code = nil
    status = nil
    begin
      # encoding header necessary to keep ruby from auto inflating archives
      f = open(encoded_url, 'rb', "Accept-Encoding" => "identity")
      code, status = f.status
      code = code.to_i
    rescue OpenURI::HTTPError => e
      code, status = e.io.status[0].to_i, e.message
      status = status.gsub(/^#{code.to_s}\s*/, '')
    end
    puts "response: #{code} #{status}"
    basename = nil
    if code == 200
      if File.directory?(path)
        puts "path is directory"
        pp f.meta
        puts "try basename from content-disposition"
        fmeta = f.meta["content-disposition"]
        if fmeta
          puts "content-disposition: " + fmeta
          match = fmeta.match(/filename=(\"?)(.+)\1/)
          if !match.blank?
            basename = match[2]
            puts "content-disposition: " + basename
          end
        else
          puts "content-disposition: none"
        end
        if basename.blank?
          puts "try basename from URI path"
          uri = URI.parse(encoded_url)
          upath = uri.path
          if !File.extname(upath).empty?
            basename = File.basename(upath)
            puts "URI path: " + basename
          else
            puts "URI path: no filename found"
          end
        end
        if (basename.blank?) and f.meta["content-type"]
          puts "try basename from mime type"
          ct = f.meta["content-type"]
          match = mt.match(/^([^;]+);?/)[1]
          if !match.empty?
            mimetype = mt.match(/^([^;]+);?/)[1]
            ext = Rack::Mime::MIME_TYPES.invert[mimetype]
            basename = "data" + ext
            puts "content-type: " + basename
          else
            puts "mime type: content-type match failed"
          end
        end
        if basename.blank?
          puts "basename not found, so: data.dat"
          basename = "data.dat"
        end
        path = File.join(path, basename)
      else
        puts "path is filename: " + path
      end
      puts "copy stream to:" + path
      IO.copy_stream(f, path)
      end_time = Time.now
      duration = (end_time - start_time).to_f
      puts "[completed in #{duration.round(1)} s]"
    else
      path = nil
      puts "download failed"
    end
    return code, status, path
  end

  def upload_stream_to(stream, fname)
    puts "uploading to #{fname}"
    start_time = Time.now
    IO.copy_stream(stream, fname)
    end_time = Time.now
    duration = (end_time - start_time).to_f
    puts "[completed in #{duration.round(1)} s]"
    return fname
  end

end
