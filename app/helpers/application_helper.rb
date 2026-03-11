module ApplicationHelper
  # Returns base_class plus the appropriate DaisyUI error modifier when the
  # object has errors on the given field.
  # Works for input/select/textarea — detects which modifier to append by
  # inspecting the base_class string.
  def field_class(object, field, base_class)
    return base_class unless object.errors[field].any?

    modifier = if base_class.include?("select")
                 "select-error"
    elsif base_class.include?("textarea")
                 "textarea-error"
    else
                 "input-error"
    end
    "#{base_class} #{modifier}"
  end
end
