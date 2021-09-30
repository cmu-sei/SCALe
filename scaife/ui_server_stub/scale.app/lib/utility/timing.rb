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

module Utility
module Timing
=begin

	timing utility functions

=end

=begin

	Retrieve timestamps needed to calculate elapsed time and cpu time

=end
	def get_timestamps()
            transaction_timestamp = Time.now
            cpu_time = Process.clock_gettime(Process::CLOCK_PROCESS_CPUTIME_ID)
            elapsed_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
            timestamps = Hash.new
            timestamps["transaction_timestamp"] = transaction_timestamp
            timestamps["elapsed_time"] = elapsed_time
            timestamps["cpu_time"] = cpu_time
            return timestamps
	end

end
end
