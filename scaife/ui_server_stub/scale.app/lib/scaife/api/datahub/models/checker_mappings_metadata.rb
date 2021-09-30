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

  class CheckerMappingsMetadata
    # Source of the mapping, e.g., CERT wiki, scale.app, etc.
    attr_accessor :mapping_source

    attr_accessor :mapper_identity

    attr_accessor :mapping_version

    attr_accessor :publishable_public_or_not

    attr_accessor :dod_publication

    attr_accessor :deprecated_or_not

    attr_accessor :license_information

    attr_accessor :additional_notes

    attr_accessor :description

    attr_accessor :mapping_date

    # 'Filename of the mappings CSV that this data describes and will be uploaded in a subsequent call'
    attr_accessor :mapping_filename

    attr_accessor :mappings

    # Attribute mapping from ruby-style variable name to JSON key.
    def self.attribute_map
      {
        :'mapping_source' => :'mapping_source',
        :'mapper_identity' => :'mapper_identity',
        :'mapping_version' => :'mapping_version',
        :'publishable_public_or_not' => :'publishable_public_or_not',
        :'dod_publication' => :'dod_publication',
        :'deprecated_or_not' => :'deprecated_or_not',
        :'license_information' => :'license_information',
        :'additional_notes' => :'additional_notes',
        :'description' => :'description',
        :'mapping_date' => :'mapping_date',
        :'mapping_filename' => :'mapping_filename',
        :'mappings' => :'mappings'
      }
    end

    # Returns all the JSON keys this model knows about
    def self.acceptable_attributes
      attribute_map.values
    end

    # Attribute type mapping.
    def self.openapi_types
      {
        :'mapping_source' => :'String',
        :'mapper_identity' => :'Array<String>',
        :'mapping_version' => :'String',
        :'publishable_public_or_not' => :'Boolean',
        :'dod_publication' => :'Boolean',
        :'deprecated_or_not' => :'Boolean',
        :'license_information' => :'String',
        :'additional_notes' => :'String',
        :'description' => :'String',
        :'mapping_date' => :'Time',
        :'mapping_filename' => :'String',
        :'mappings' => :'Array<CheckerCondition>'
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
        fail ArgumentError, "The input argument (attributes) must be a hash in `Scaife::Api::Datahub::CheckerMappingsMetadata` initialize method"
      end

      # check to see if the attribute exists and convert string to symbol for hash key
      attributes = attributes.each_with_object({}) { |(k, v), h|
        if (!self.class.attribute_map.key?(k.to_sym))
          fail ArgumentError, "`#{k}` is not a valid attribute in `Scaife::Api::Datahub::CheckerMappingsMetadata`. Please check the name to make sure it's valid. List of attributes: " + self.class.attribute_map.keys.inspect
        end
        h[k.to_sym] = v
      }

      if attributes.key?(:'mapping_source')
        self.mapping_source = attributes[:'mapping_source']
      end

      if attributes.key?(:'mapper_identity')
        if (value = attributes[:'mapper_identity']).is_a?(Array)
          self.mapper_identity = value
        end
      end

      if attributes.key?(:'mapping_version')
        self.mapping_version = attributes[:'mapping_version']
      end

      if attributes.key?(:'publishable_public_or_not')
        self.publishable_public_or_not = attributes[:'publishable_public_or_not']
      end

      if attributes.key?(:'dod_publication')
        self.dod_publication = attributes[:'dod_publication']
      end

      if attributes.key?(:'deprecated_or_not')
        self.deprecated_or_not = attributes[:'deprecated_or_not']
      end

      if attributes.key?(:'license_information')
        self.license_information = attributes[:'license_information']
      end

      if attributes.key?(:'additional_notes')
        self.additional_notes = attributes[:'additional_notes']
      end

      if attributes.key?(:'description')
        self.description = attributes[:'description']
      end

      if attributes.key?(:'mapping_date')
        self.mapping_date = attributes[:'mapping_date']
      end

      if attributes.key?(:'mapping_filename')
        self.mapping_filename = attributes[:'mapping_filename']
      end

      if attributes.key?(:'mappings')
        if (value = attributes[:'mappings']).is_a?(Array)
          self.mappings = value
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
          mapping_source == o.mapping_source &&
          mapper_identity == o.mapper_identity &&
          mapping_version == o.mapping_version &&
          publishable_public_or_not == o.publishable_public_or_not &&
          dod_publication == o.dod_publication &&
          deprecated_or_not == o.deprecated_or_not &&
          license_information == o.license_information &&
          additional_notes == o.additional_notes &&
          description == o.description &&
          mapping_date == o.mapping_date &&
          mapping_filename == o.mapping_filename &&
          mappings == o.mappings
    end

    # @see the `==` method
    # @param [Object] Object to be compared
    def eql?(o)
      self == o
    end

    # Calculates hash code according to all attributes.
    # @return [Integer] Hash code
    def hash
      [mapping_source, mapper_identity, mapping_version, publishable_public_or_not, dod_publication, deprecated_or_not, license_information, additional_notes, description, mapping_date, mapping_filename, mappings].hash
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
