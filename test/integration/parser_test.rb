require 'test_helper'

require 'jekyll/gem_resolver/parser'

class ParserTest < Minitest::Test
  def test_ignores_non_string_values
    # Everything that is not a String is ignored
    assert_ignored []
    assert_ignored ["array"]
    assert_ignored({'just' => 'an-object'})
    assert_ignored({some_property: 'with-a-value'})
    assert_ignored 123
    assert_ignored 1.5

  end

  def test_ignores_other_strings
    assert_ignored ''
    assert_ignored 'not-a-reference'
    assert_ignored '/'
    assert_ignored '/absolute/path/'
    assert_ignored 'relative/nested/path'
    assert_ignored ':packagetype/is/missing'
    assert_ignored 'gem'
    assert_ignored 'gem:'
    assert_ignored 'gem:/packagename/is/missing'
    assert_ignored 'gem::packagename/is/missing'
  end

  def test_matches_only_whole_string
    assert_ignored ' gem:preceding/spaces/are/not/allowed'
    assert_ignored ' gem:preceding/spaces:are/not/allowed'
  end

  def test_parses_single_colon_syntax
    assert_parsed 'gem:nameonly', { type: 'gem', name: 'nameonly', path: "" }
    assert_parsed 'gem:bootstrap/assets/stylesheets', { type: 'gem', name: 'bootstrap', path: '/assets/stylesheets' }
    assert_parsed 'gem:package1with2numbers3/nested/path', { type: 'gem', name: 'package1with2numbers3', path: '/nested/path' }
    assert_parsed 'gem:package-with-dashes/some/deeply/nested/path', { type: 'gem', name: 'package-with-dashes', path: '/some/deeply/nested/path' }
    assert_parsed 'gem:package_with_underscores/assets/stylesheets', { type: 'gem', name: 'package_with_underscores', path: '/assets/stylesheets' }
  end

  def test_parses_double_colon_syntax
    assert_parsed 'gem:bootstrap:assets/stylesheets', { type: 'gem', name: 'bootstrap', path: '/assets/stylesheets' }
    assert_parsed 'gem:package1with2numbers3:nested/path', { type: 'gem', name: 'package1with2numbers3', path: '/nested/path' }
    assert_parsed 'gem:package-with-dashes:some/deeply/nested/path', { type: 'gem', name: 'package-with-dashes', path: '/some/deeply/nested/path' }
    assert_parsed 'gem:package_with_underscores:assets/stylesheets', { type: 'gem', name: 'package_with_underscores', path: '/assets/stylesheets' }
    assert_parsed 'gem:organization/nested/package:assets/javascript', { type: 'gem', name: 'organization/nested/package', path: '/assets/javascript' }
  end

  def assert_parsed(input, expected_result)
    result = Jekyll::GemResolver::PackageReferenceParser.new().try_parse(input)
    assert_equal(expected_result[:type], result.type)
    assert_equal(expected_result[:name], result.name)
    assert_equal(expected_result[:path], result.relative_path)
  end

  def assert_ignored(input)
    result = Jekyll::GemResolver::PackageReferenceParser.new().try_parse(input)
    assert_nil(result)
  end
end