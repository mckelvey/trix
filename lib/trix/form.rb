require 'action_view'
require 'active_support/core_ext'

module TrixEditorHelper
  mattr_accessor(:id, instance_accessor: false)
  class_variable_set('@@id', 0)

  def trix_editor_tag(name, value = nil, options = {})
    options.symbolize_keys!

    input_options = options.has_key?(:input_options) ? options.delete(:input_options) : {}

    attributes = options.merge({
      class: "formatted_content #{options[:class]}".squish,
      input: options[:input].blank? ? "trix_input_#{TrixEditorHelper.id += 1}" : options[:input]
    })

    editor_tag = content_tag('trix-editor', '', attributes)

    input_options.merge!({
      id: attributes[:input],
      data: (input_options[:data] || {}).merge({ 'original-value': value })
    })
    input_tag = hidden_field_tag(name, value, input_options)

    editor_tag + input_tag
  end
end

module ActionView
  module Helpers
    include TrixEditorHelper

    module Tags
      class TrixEditor < Base
        include TrixEditorHelper
        delegate :dom_id, to: :'@template_object'

        def render
          options = @options.stringify_keys
          add_default_name_and_id(options)
          options['input'] ||= dom_id(object, [options['id'], :trix_input].compact.join('_'))
          trix_editor_tag(options.delete('name'), value_before_type_cast(object), options)
        end
      end
    end

    module FormHelper
      def trix_editor(object_name, method, options = {})
        Tags::TrixEditor.new(object_name, method, self, options).render
      end
    end

    class FormBuilder
      def trix_editor(method, options = {})
        @template.trix_editor(@object_name, method, objectify_options(options))
      end
    end
  end
end
