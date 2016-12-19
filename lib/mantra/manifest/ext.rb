module Mantra
  class Manifest
    module Ext
      def self.included(base)
        base.send :extend, ClassMethods
        base.send :include, InstanceMethods
      end

      module ClassMethods
      end

      module InstanceMethods

        def properties
          job_properties = Element.create({}).content
          job_properties_array = self.jobs.map do |job|
            job.hash? ? job.content["properties"] : nil
          end.compact
          job_properties_array.each do |jp|
            job_properties.merge(jp)
          end
          manifest_properties = self.root.child.hash? ? self.root.child.content["properties"] : Element.create({}).content
          manifest_properties.merge(job_properties)
          manifest_properties
        end

        def jobs
          self.root.content.hash? ? self.root.content.content["jobs"] : nil
        end
      end
    end
  end
end
