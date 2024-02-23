require 'jekyll/gem_resolver/transformer'

Jekyll::Hooks.register :site, :after_init do |site|
  Jekyll::GemResolver::ConfigTransformer.new().transform_site_config(site)
end
