#
# Custom FormBuilder
#
# Author:  Michael Pope
# Version: 1.01

class SuperFormBuilder < ActionView::Helpers::FormBuilder

  # Create an array of helpers to override with our label builder
  helpers = field_helpers +
            %w{calendar_date_select date_select datetime_select time_select} +
            %w{collection_select select country_select time_zone_select} -
            %w{hidden_field label fields_for} # Don't decorate these

  helpers.each do |name|

    # name = the type of object (text_field, etc)
    define_method(name) do |field, *args|

      # Get the hash option (EG the field involved)
      options = args.extract_options!

      # Create a label for that field
      label = label(field, options[:label], :class => options[:label_class])

      # Create an inline error
      error = error_message_on(field)

      # Wrap label in paragraph, include the original helper EG: text-field
      @template.content_tag(:p, label + @template.tag("br") + super + error)  #wrap with a paragraph
    end
  end

  # Override the submit button
  def submit
    # Calculate custom text for submit button.
    prefix = object.new_record? ? "Create" : "Update"

    # Wrap submit button in paragraph tags and add custom text.
    @template.content_tag(:p,super(prefix, :id => "apply" ))
  end
end

