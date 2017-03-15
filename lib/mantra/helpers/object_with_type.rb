module Mantra
  module Helpers
    module ObjectWithType

      class UnknownType < Exception; end
      class UnspecifiedType < Exception; end

      def self.included(base)
        base.send :extend, ClassMethods
        base.send :include, InstanceMethods
      end

      module ClassMethods
        def type(type=nil)
          type.nil? ? @type : (@type = type.to_sym)
        end

        def alias_type(alias_type)
          aliases(alias_type)
        end

        def aliases(*args)
          @aliases = [] if @aliases.nil?
          args.empty? ? @aliases : (@aliases.concat(args.map {|a| a.to_sym }))
        end

        def create(options)
          type = options[:type] || options["type"]
          raise UnspecifiedType.new("options hash should contain type") if type.nil?
          subclass = self.find_by_type(type.to_sym)
          if subclass.nil?
            raise UnknownType.new("unknown type #{type}")
          else
            subclass.new(options)
          end
        end

        def find_by_type(type)
          self.subclasses.find { |s| s.type == type || s.aliases.include?(type) }
        end

        def inherited(subclass)
          subclasses << subclass
          super
        end

        def subclasses
          @subclasses ||= []
        end
      end

      module InstanceMethods
        def type
          self.class.type
        end

        attr_accessor :options

        def initialize(options={})
          @options = options
        end
      end
    end
  end
end
