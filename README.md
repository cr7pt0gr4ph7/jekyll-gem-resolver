# jekyll-gem-resolver
[![Gem Version](https://badge.fury.io/rb/jekyll-gem-resolver.png)](https://badge.fury.io/rb/jekyll-gem-resolver)

Simple Jekyll plugin that enables including resources from non-Jekyll gems into the site build.

### Purpose

When enabled, the plugin scans certain, configurable parts of your `_config.yml` file for references of the form `"gem:package:path/in/package"` (or `"gem:package/path/in/package"`) and replaces them with absolute paths to the correct Gem directory/file, using the Gem version specified in your `Gemfile` / `Gemfile.lock`.

### History

The origin of this plugin is that I wanted to build [Bootstrap][bootstrap-website]
from source using Jekyll's SASS processor and the [boostrap gem][bootstrap-rubygem]. But there is no easy way to reference the external files of the `bootstrap` gem
in your `_config.yml`, except for using absolute paths, which feels unsatisfying for a number of reasons.
This plugin was born to resolve this problem.

## Installation

This plugin is available as a [RubyGem][published-ruby-gem].

Add this line to your application's `Gemfile`:

```
gem 'jekyll-gem-resoler'
```

And then execute the `bundle` command to install the gem.

Alternatively, you can also manually install the gem using the following command:

```
$ gem install jekyll-gem-resolver
```

After the plugin has been installed successfully, add the following lines to your `_config.yml` in order to tell Jekyll to use the plugin:

```yaml
plugins:
- jekyll-gem-resolver

gem_resolver:
  transform:
    - sass.load_paths
```

## Usage

A typical configuration could look like this:

```ruby
# Excerpt from <your_directory>/Gemfile
source "https://rubygems.org"

# Or whatever version of Jekyll you are using
gem "jekyll", "~> 4.3.3"

# Declare the gems that you want to reference
gem "bootstrap", "~> 5.3.2"

group :jekyll_plugins do
  gem "jekyll-gem-resolver", "~> 1.0"
end
```

```yaml
# Excerpt from <your_directory>/_config.yml
plugins:
  - jekyll-gem-resolver

# A configuration for another plugin that references files and/or folders from a Gem
sass:
  load_paths:
    - 'gem:bootstrap/assets/stylesheets'


# Tell jekyll-gem-resolver where in the configuration to look for
# "gem:" references. The format is explained below.
gem_resolver:
  transform:
    - sass.load_paths"
```

The usage of the plugin is split into two parts:

1. Specifying where in the configuration `gem:` paths might appear
   using a JSONPath-like language.

2. Using a `gem:<..>` reference in those places in the configuration.

### Gem Reference Syntax

Gem references are written like this `"gem:package_name:path/in/package"` (or `"gem:package_name/path/in/package"`, if `package_name` does not contain a `'/'` character), which is resolved to something like:

```
/home/<your_username>/.gems/gems/<package_name>@<version_from_gemfile>/<path_in_package>
```

Note that you have to use **double or single quotes** around the `gem:` references in your YAML file,
because without it, the `gem:` prefix would erroneously be parsed as a hash by the YAML parer.

### Path Syntax

A path consists of multiple segments separated by a `'.'` character.
Each segment is either:

- an identifier (e.g. `myplugin.config_setting`, for hash elements),
- a number (e.g. `myplugin.items.1`, for array elements), or
- the string `*` (e.g. `myplugin.items.*.ident`, meaning "all elements of this array or hash").

Each segment can optionally be wrapped in `[brackets]`,
which is just syntatic sugar for the same thing without brackets. By convention, we write array indidces and `*` in brackets, and hash elements without:

```
my_plugin.array.[1]
my_plugin.array.[*]
my_plugin.hash.something
my_plugin.hash.[*]
```

When referring to all items of an array as the last segment of a path (e.g. `my_plugin.array.[*]`), you can omit the final `*` and just write it as: `my_plugin.array`.

#### Some more examples

```yaml
# You can process global settings
global_setting: "gem:example" # Matched by: "global-setting"

# You process items in arrays
global_array:
  - "gem:package1/assets/js" #  Matched by "global_array", "global_array.[*]" and "global_array.[0]"
  - "gem:package2/assets/css" # Matched by "global_array", "global_array.[*]" and "global_array.[1]"
  - "gem:package3/assets/js" #  Matched by "global_array", "global_array.[*]" and "global_array.[2]"

# You can transform items in nested arrays as well
my_plugin:
  - name: "I don't know"
    children:
      # Matched by:
      #   "my_plugin.[*].children"
      #   "my_plugin.[*].children.[*]"
      #   "my_plugin.[*].children.[1]
      #   "my_plugin.[0].children.[*]
      #   "my_plugin.[0].children.[1]"
      - "gem:package1/assets/js"

  - name: "I don't know either"
    children:
      # Matched by:
      #   "my_plugin.[*].children"
      #   "my_plugin.[*].children.[*]"
      #   "my_plugin.[*].children.[0]
      #   "my_plugin.[1].children.[*]
      #   "my_plugin.[1].children.[0]"
      - "gem:package2/assets/css"
      # Matched by:
      #   "my_plugin.[*].children"
      #   "my_plugin.[*].children.[*]"
      #   "my_plugin.[*].children.[1]
      #   "my_plugin.[1].children.[*]
      #   "my_plugin.[1].children.[1]"
      - "gem:package3/assets/js"

# You can even process items in hashes
categories:
  category_a:
    # Matched by:
    #   "categories.category_a.template_styles
    #   "categories.[*].template_styles
    template_styles: "gem:package4/templates/"
  category_b:
    # Matched by:
    #   "categories.category_a.template_styles
    #   "categories.[*].template_styles
    template_styles: "gem:package4/templates/"

# Note that omission of the final ".[*]" only works for arrays,
# not for hashes:
my_other_plugin:
  config_dict:
    # The string values below are matched by "my_other_plugin.config_dict.[*]",
    # but NOT by "my_other_plugin.config_dict".
    entry_a: "gem:package5/abc"
    entry_b: "gem:package5/def"
    entry_c: "gem:package5/ghi"
```

# Contribute
Fork this repository, make your changes and then issue a pull request. If you find bugs or have new ideas that you do not want to implement yourself, file a bug report.

# Copyright
Copyright (c) 2024 Lukas Waslowski.

License: MIT

[bootstrap-website]: https://getbootstrap.com
[bootstrap-rubygem]: https://github.com/twbs/bootstrap-rubygem
[published-ruby-gem]: https://rubygems.org/gems/jekyll-gem-resolver
