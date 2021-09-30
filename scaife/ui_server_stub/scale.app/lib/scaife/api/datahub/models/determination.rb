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

require 'date'
require 'time'

module Scaife
module Api
module Datahub

  class Determination
    attr_accessor :flag_list

    attr_accessor :verdict_list

    attr_accessor :ignored_list

    attr_accessor :dead_list

    attr_accessor :inapplicable_environment_list

    attr_accessor :dangerous_construct_list

    attr_accessor :notes_list

    # Attribute mapping from ruby-style variable name to JSON key.
    def self.attribute_map
      {
        :'flag_list' => :'flag_list',
        :'verdict_list' => :'verdict_list',
        :'ignored_list' => :'ignored_list',
        :'dead_list' => :'dead_list',
        :'inapplicable_environment_list' => :'inapplicable_environment_list',
        :'dangerous_construct_list' => :'dangerous_construct_list',
        :'notes_list' => :'notes_list'
      }
    end

    # Returns all the JSON keys this model knows about
    def self.acceptable_attributes
      attribute_map.values
    end

    # Attribute type mapping.
    def self.openapi_types
      {
        :'flag_list' => :'Array<DeterminationFlagList>',
        :'verdict_list' => :'Array<DeterminationVerdictList>',
        :'ignored_list' => :'Array<DeterminationIgnoredList>',
        :'dead_list' => :'Array<DeterminationDeadList>',
        :'inapplicable_environment_list' => :'Array<DeterminationInapplicableEnvironmentList>',
        :'dangerous_construct_list' => :'Array<DeterminationDangerousConstructList>',
        :'notes_list' => :'Array<DeterminationNotesList>'
      }
    end

    # List of attributes with nullable: true
    def self.openapi_nullable
      Set.new([
      ])
    end

    # Initializes the object
    # @param [Hash] attributes Model attributes in the form of hash
    def initialize(attributes = {})
      if (!attributes.is_a?(Hash))
        fail ArgumentError, "The input argument (attributes) must be a hash in `Scaife::Api::Datahub::Determination` initialize method"
      end

      # check to see if the attribute exists and convert string to symbol for hash key
      attributes = attributes.each_with_object({}) { |(k, v), h|
        if (!self.class.attribute_map.key?(k.to_sym))
          fail ArgumentError, "`#{k}` is not a valid attribute in `Scaife::Api::Datahub::Determination`. Please check the name to make sure it's valid. List of attributes: " + self.class.attribute_map.keys.inspect
        end
        h[k.to_sym] = v
      }

      if attributes.key?(:'flag_list')
        if (value = attributes[:'flag_list']).is_a?(Array)
          self.flag_list = value
        end
      end

      if attributes.key?(:'verdict_list')
        if (value = attributes[:'verdict_list']).is_a?(Array)
          self.verdict_list = value
        end
      end

      if attributes.key?(:'ignored_list')
        if (value = attributes[:'ignored_list']).is_a?(Array)
          self.ignored_list = value
        end
      end

      if attributes.key?(:'dead_list')
        if (value = attributes[:'dead_list']).is_a?(Array)
          self.dead_list = value
        end
      end

      if attributes.key?(:'inapplicable_environment_list')
        if (value = attributes[:'inapplicable_environment_list']).is_a?(Array)
          self.inapplicable_environment_list = value
        end
      end

      if attributes.key?(:'dangerous_construct_list')
        if (value = attributes[:'dangerous_construct_list']).is_a?(Array)
          self.dangerous_construct_list = value
        end
      end

      if attributes.key?(:'notes_list')
        if (value = attributes[:'notes_list']).is_a?(Array)
          self.notes_list = value
        end
      end
    end

    # Show invalid properties with the reasons. Usually used together with valid?
    # @return Array for valid properties with the reasons
    def list_invalid_properties
      invalid_properties = Array.new
      invalid_properties
    end

    # Check to see if the all the properties in the model are valid
    # @return true if the model is valid
    def valid?
      true
    end

    # Checks equality by comparing each attribute.
    # @param [Object] Object to be compared
    def ==(o)
      return true if self.equal?(o)
      self.class == o.class &&
          flag_list == o.flag_list &&
          verdict_list == o.verdict_list &&
          ignored_list == o.ignored_list &&
          dead_list == o.dead_list &&
          inapplicable_environment_list == o.inapplicable_environment_list &&
          dangerous_construct_list == o.dangerous_construct_list &&
          notes_list == o.notes_list
    end

    # @see the `==` method
    # @param [Object] Object to be compared
    def eql?(o)
      self == o
    end

    # Calculates hash code according to all attributes.
    # @return [Integer] Hash code
    def hash
      [flag_list, verdict_list, ignored_list, dead_list, inapplicable_environment_list, dangerous_construct_list, notes_list].hash
    end

    # Builds the object from hash
    # @param [Hash] attributes Model attributes in the form of hash
    # @return [Object] Returns the model itself
    def self.build_from_hash(attributes)
      new.build_from_hash(attributes)
    end

    # Builds the object from hash
    # @param [Hash] attributes Model attributes in the form of hash
    # @return [Object] Returns the model itself
    def build_from_hash(attributes)
      return nil unless attributes.is_a?(Hash)
      self.class.openapi_types.each_pair do |key, type|
        if attributes[self.class.attribute_map[key]].nil? && self.class.openapi_nullable.include?(key)
          self.send("#{key}=", nil)
        elsif type =~ /\AArray<(.*)>/i
          # check to ensure the input is an array given that the attribute
          # is documented as an array but the input is not
          if attributes[self.class.attribute_map[key]].is_a?(Array)
            self.send("#{key}=", attributes[self.class.attribute_map[key]].map { |v| _deserialize($1, v) })
          end
        elsif !attributes[self.class.attribute_map[key]].nil?
          self.send("#{key}=", _deserialize(type, attributes[self.class.attribute_map[key]]))
        end
      end

      self
    end

    # Deserializes the data based on type
    # @param string type Data type
    # @param string value Value to be deserialized
    # @return [Object] Deserialized data
    def _deserialize(type, value)
      case type.to_sym
      when :Time
        Time.parse(value)
      when :Date
        Date.parse(value)
      when :String
        value.to_s
      when :Integer
        value.to_i
      when :Float
        value.to_f
      when :Boolean
        if value.to_s =~ /\A(true|t|yes|y|1)\z/i
          true
        else
          false
        end
      when :Object
        # generic object (usually a Hash), return directly
        value
      when /\AArray<(?<inner_type>.+)>\z/
        inner_type = Regexp.last_match[:inner_type]
        value.map { |v| _deserialize(inner_type, v) }
      when /\AHash<(?<k_type>.+?), (?<v_type>.+)>\z/
        k_type = Regexp.last_match[:k_type]
        v_type = Regexp.last_match[:v_type]
        {}.tap do |hash|
          value.each do |k, v|
            hash[_deserialize(k_type, k)] = _deserialize(v_type, v)
          end
        end
      else # model
        # models (e.g. Pet) or oneOf
        klass = Scaife::Api::Datahub.const_get(type)
        klass.respond_to?(:openapi_one_of) ? klass.build(value) : klass.build_from_hash(value)
      end
    end

    # Returns the string representation of the object
    # @return [String] String presentation of the object
    def to_s
      to_hash.to_s
    end

    # to_body is an alias to to_hash (backward compatibility)
    # @return [Hash] Returns the object in the form of hash
    def to_body
      to_hash
    end

    # Returns the object in the form of hash
    # @return [Hash] Returns the object in the form of hash
    def to_hash
      hash = {}
      self.class.attribute_map.each_pair do |attr, param|
        value = self.send(attr)
        if value.nil?
          is_nullable = self.class.openapi_nullable.include?(attr)
          next if !is_nullable || (is_nullable && !instance_variable_defined?(:"@#{attr}"))
        end

        hash[param] = _to_hash(value)
      end
      hash
    end

    # Outputs non-array value in the form of hash
    # For object, use to_hash. Otherwise, just return the value
    # @param [Object] value Any valid value
    # @return [Hash] Returns the value in the form of hash
    def _to_hash(value)
      if value.is_a?(Array)
        value.compact.map { |v| _to_hash(v) }
      elsif value.is_a?(Hash)
        {}.tap do |hash|
          value.each { |k, v| hash[k] = _to_hash(v) }
        end
      elsif value.respond_to? :to_hash
        value.to_hash
      else
        value
      end
    end

  end

end
end
end