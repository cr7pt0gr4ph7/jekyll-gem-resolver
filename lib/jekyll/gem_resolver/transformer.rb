require 'jekyll'
require 'jekyll/gem_resolver/parser'
require 'jekyll/gem_resolver/resolver'

module Jekyll
  module GemResolver
    class ConfigTransformer
      def initialize(parser = nil, resolver = nil)
        @parser = parser || Jekyll::GemResolver::PackageReferenceParser.new()
        @resolver = resolver || Jekyll::GemResolver::PackageReferenceResolver.new()
      end

      def transform_site_config(site)
        transform_yaml(site.config)
      end

      def transform_yaml(config)
        options = config['gem_resolver'] || {}
        (options['transform'] || []).each { |path_to_transform| transform_config_node(config, path_to_transform.split('.')) }
        config
      end

      private

      def transform_config_node(node, path, use_fallbacks = true)
        # Have we arrived at the last segment of the path?
        if path.nil? || path.empty?
          # Special behavior: If this node is an array, behave as if path contains an additional '.*'
          return transform_config_node(node, ['*'], false) if node.is_a?(Array) && use_fallbacks

          # Not an array: Directly process this node
          return transform_config_value(node)
        end

        # The path has at least one remaining segment
        key = strip_brackets(path[0])
        remaining_path = path[1..-1]

        if node.is_a? Array
          if key == '*'
            # Transform each value in this array recursively
            node.map! { |value| transform_config_node(value, remaining_path)  }
          else
            # Recurse into the specified array item
            index = Integer(key)
            node[index] = transform_config_node(node[index], remaining_path)
          end
        elsif node.is_a? Hash
          if key == '*'
            # Transform each value in this hash recursively
            node.transform_values! { |value| transform_config_node(value, remaining_path)  }
          else
            # Recurse into the specified hash value
            node[key] = transform_config_node(node[key], remaining_path)
          end
        else
          # The path has remaining segments, but this is a leaf node.
          # This means that the specified path does not match, and we therefore
          # do not modify or transform this node.
        end

        return node
      end

      def strip_brackets(text)
          return text unless text
          return text.gsub(/^\[(.+)\]$/, '\1')
      end

      def transform_config_value(value)
        return value unless value.is_a? String # Not a package reference, ignore

        package_ref = @parser.try_parse(value)
        return value if package_ref.nil? # Not a package reference, ignore

        result = @resolver.resolve(package_ref)
        Jekyll.logger.error("Failed to resolve package reference #{value}") if result.nil?
        Jekyll.logger.info("Resolved #{value} to #{result}") unless result.nil?
        result
      end
    end
  end
end