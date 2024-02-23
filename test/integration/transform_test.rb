require 'yaml'
require 'test_helper'
require 'jekyll/gem_resolver/transformer'

class TransformTest < Minitest::Test
  def test_does_nothing_when_not_configured
      input = <<~END_YAML
        unconfigured_path:
          - 'gem:mypackage1/relative/path'
        sass:
          load_paths:
            - 'gem:mypackage2/another/nested/path'
      END_YAML

      expected_result = <<~END_YAML
        unconfigured_path:
          - 'gem:mypackage1/relative/path'
        sass:
          load_paths:
            - 'gem:mypackage2/another/nested/path'
      END_YAML

      assert_transformed_equals(input, expected_result)
  end

  def test_transforms_only_configured_paths
    input = <<~END_YAML
      unconfigured_path:
        - 'gem:mypackage1/relative/path'
      sass:
        load_paths:
        - 'gem:mypackage2/some/nested/path'
        - 'gem:mypackage3/another/nested/path'
        - 'gem:mypackage4:deeply/nested/path'
      gem_resolver:
        transform:
          - sass.load_paths
    END_YAML

    expected_result = <<~END_YAML
      unconfigured_path:
        - 'gem:mypackage1/relative/path'
      sass:
        load_paths:
          - gem|mypackage2|/some/nested/path
          - gem|mypackage3|/another/nested/path
          - gem|mypackage4|/deeply/nested/path
      gem_resolver:
        transform:
          - sass.load_paths
    END_YAML

    assert_transformed_equals(input, expected_result)
  end

  def assert_transformed_equals(input_yaml, expected_output_yaml)
      input = YAML::load(input_yaml)
      actual_output = Jekyll::GemResolver::ConfigTransformer.new(nil, MockResolver.new()).transform_yaml(input)
      actual_output_yaml = YAML::dump(actual_output)
      assert_equal(YAML::dump(YAML::load(expected_output_yaml)), actual_output_yaml)
  end

  class MockResolver
    def resolve(pkg)
      return "#{pkg.type}|#{pkg.name}|#{pkg.relative_path}"
    end
  end
end