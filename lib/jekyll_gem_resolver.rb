module JekyllGemResolver
  def self.transform_config(site)
    options = site.config['gem_resolver'] || {}
    (options['transform'] || []).each { |path_to_transform| transform_config_node(site.config, path_to_transform.split('.')) }
  end

  private

  def self.transform_config_node(node, path, use_fallbacks = true)
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

  def self.strip_brackets(text)
      return text unless text
      return text.gsub(/^\[(.+)\]$/, '\1')
  end

  def self.transform_config_value(value)
    return value unless value.is_a? String

    result = if /^gem:(?<gem_name>[^:]+):(?<relative_path>.*)/ =~ value
      resolve_gem(gem_name, "/#{relative_path}")
    elsif /^gem:(?<gem_name>[^\/]+)(?<relative_path>.*)/ =~ value
      resolve_gem(gem_name, relative_path)
    else
      nil
    end

    Jekyll.logger.info("Resolved #{value} to #{result}") unless result.nil?
    result
  end

  def self.resolve_gem(gem_name, relative_path)
    spec = Gem::Specification.find_by_name(gem_name)
    spec.gem_dir + relative_path
  end

  Jekyll::Hooks.register :site, :after_init do |site|
    transform_config(site)
  end
end
