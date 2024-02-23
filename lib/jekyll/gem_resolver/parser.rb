module Jekyll
  module GemResolver
    class PackageReference
      attr_reader :type, :name, :relative_path

      def initialize(package_type, package_name, relative_path)
        @type = package_type
        @name = package_name
        @relative_path = relative_path
      end
    end

    class PackageReferenceParser
      def try_parse(value)
        return nil unless value.is_a? String

        if /^gem:(?<gem_name>[^:]+):(?<relative_path>.*)/ =~ value
          PackageReference.new('gem', gem_name, "/#{relative_path}")
        elsif /^gem:(?<gem_name>[^\/:]+)(?<relative_path>.*)/ =~ value
          PackageReference.new('gem', gem_name, relative_path)
        else
          nil
        end
      end

    end
  end
end