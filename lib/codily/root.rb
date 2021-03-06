require 'fastly'
require 'codily/elements/service'

module Codily
  class Root
    class AlreadyDefined < StandardError; end

    def initialize(debug: false, service_filter: nil)
      @debug = debug
      @elements = {}

      @service_filter = service_filter
      @service_versions = {}
      @service_map_name_to_id = {}
    end

    attr_reader :elements
    attr_reader :service_filter
    attr_reader :service_versions
    attr_accessor :debug

    def as_hash
      {}
    end

    def as_dsl_hash
      as_hash
    end

    # XXX: is it okay having this here?
    def service_version_set(service_name, service_id, versions)
      @service_map_name_to_id[service_name] = service_id
      dev_version = versions.reverse_each.find { |_| !_.locked }
      dev = dev_version && dev_version.number
      active = (versions.reverse_each.find(&:active) || versions.reverse_each.find(&:locked)).number
      @service_versions[service_id] = {dev: dev, active: active, name: service_name, id: service_id}
    end

    def service_version_get(name_or_id)
      @service_versions[@service_map_name_to_id[name_or_id] || name_or_id]
    end

    def services
      list_element(Elements::Service)
    end

    def service(name, &block)
      if service_filter
        return nil unless service_filter.any? { |_| _ === name }
      end

      raise AlreadyDefined if services.key?(name)
      add_element(Elements::Service.new(self, {name: name}, &block))
    end


    def run_block(&block)
      raise ArgumentError, 'block not given' unless block

      instance_eval &block
      self
    end

    def run_string(str, file = '(eval)', line = 1)
      instance_eval str, file, line
      self
    end


    def add_element(element)
      h = (@elements[element.class] ||= {})
      raise AlreadyDefined, "#{element.class.name}(#{element.key}) is already defined: (#{h.keys.inspect})" if h.key?(element.key)
      if debug
        puts "DEBUG: #{self.class}/#{'%x' % self.__id__}(add_element): #{element.class}(#{element.key.inspect}) #{element.as_hash.inspect}"
      end
      h[element.key] = element
    end

    def list_element(klass)
      @elements[klass] ||= {}
    end

    def find_element(element)
      list_element(element.class)[element.key]
    end

    def all_elements
      @elements.each_value.flat_map(&:values)
    end
  end
end
