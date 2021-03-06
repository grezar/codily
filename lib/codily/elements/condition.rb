require 'codily/elements/service_belongging_base'

module Codily
  module Elements
    class Condition < ServiceBelonggingBase
      def_attr *%i(
        comment
        priority
        statement
      )

      def setup
        delete_if_empty! *%i(
          comment
        )
        force_integer! *%i(
          priority
        )
      end

      def type(obj = nil)
        getset :type, obj.to_s.upcase
      end

      def fastly_class
        Fastly::Condition
      end
    end
  end
end
