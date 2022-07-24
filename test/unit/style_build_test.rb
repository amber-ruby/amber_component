# # frozen_string_literals: true

# require 'test_helper'
# require 'nokogiri'
# require 'sassc'

# require_relative './fixtures/styled_component'
# require_relative './fixtures/method_styled_component'
# require_relative './fixtures/scss_method_styled_component'

# class ::StyleBuildTest < ::TestCase
#   def test_that_is_able_to_build_style_from_file
#     view = StyledComponent.()
#     doc = Nokogiri::HTML(view)

#     assert doc.css('.card').any?
#     style_tag = doc.css('style').first
#     assert style_tag.text.include?('.card')
#     assert style_tag.text.include?('.card-title')
#     assert style_tag.text.include?('.card-content')
#   end

#   def test_that_is_able_to_build_from_class_method
#     view = MethodStyledComponent.()
#     doc = Nokogiri::HTML(view)
#     style_tag = doc.css('style').first
#     assert_equal style_tag.text, <<~HTML
#     p {
#       font-size: bold; }
#     HTML
#   end

#   def test_that_is_able_to_build_from_class_method_with_scss
#     view = ScssMethodStyledComponent.()
#     doc = Nokogiri::HTML(view)
#     style_tag = doc.css('style').first
#     assert_equal style_tag.text, ".card p {\n  font-size: bold; }\n  .card p:hover {\n    color: red; }\n"
#   end
# end
