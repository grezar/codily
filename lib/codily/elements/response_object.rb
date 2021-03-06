require 'codily/elements/service_belongging_base'
require 'codily/elements/condition'
require 'codily/elements/file_loadable'

module Codily
  module Elements
    class ResponseObject < ServiceBelonggingBase
      include FileLoadable

      def_attr *%i(
        content_type
        status
        response
        cache_condtiion
        request_condition
      )

      defaults(
        content: "",
        content_type: "",
        response: "",
      )

      def setup
        delete_if_empty! *%i(
          content
          content_type
          response
          cache_condition
          request_condition
        )
        force_integer! *%i(
          status
        )
      end

      def content(obj = nil)
        getset :content, file_loadable(obj)
      end

      def cache_condition(name = nil, &block)
        set_refer_element(:cache_condition, Condition, {name: name, type: 'CACHE', _service_name: self.service_name}, &block)
      end

      def request_condition(name = nil, &block)
        set_refer_element(:request_condition, Condition, {name: name, type: 'REQUEST', _service_name: self.service_name}, &block)
      end

      def fastly_class
        Fastly::ResponseObject
      end
    end
  end
end
