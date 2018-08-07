# -*- coding: utf-8 -*-
# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved. See COPYRIGHT file for details.


class Message < ActiveRecord::Base
	# A message belongs to a particular display, and
	# only contains a message, path, line, and the ID of the
	# diagnostic it belongs to. 
	has_one :display
    attr_accessible :message, :diagnostic_id, :path, :line
end
