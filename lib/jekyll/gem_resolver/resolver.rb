require 'jekyll'

module Jekyll
  module GemResolver
    class PackageReferenceResolver
      def resolve_reference(pkg)
        case pkg.type
        when 'gem'
          resolve_gem(pkg.name, pkg.relative_path)
        else
          Jekyll.logger.error("Unsupported package reference type #{package_type.inspect}")
        end
      end

      private

      def resolve_gem(gem_name, relative_path)
        spec = Gem::Specification.find_by_name(gem_name)
        spec.gem_dir + relative_path
      end
    end
  end
end