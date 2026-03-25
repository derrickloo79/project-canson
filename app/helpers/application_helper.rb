module ApplicationHelper
  # Returns base_class plus the appropriate DaisyUI error modifier when the
  # object has errors on the given field.
  # Works for input/select/textarea — detects which modifier to append by
  # inspecting the base_class string.
  AVATAR_COLORS = %w[
    bg-red-600 bg-orange-600 bg-amber-700 bg-green-700 bg-emerald-700
    bg-teal-700 bg-cyan-700 bg-sky-700 bg-blue-600 bg-indigo-600
    bg-violet-600 bg-purple-600 bg-fuchsia-600 bg-pink-600 bg-rose-600
  ].freeze

  def avatar_color(user)
    AVATAR_COLORS[user.id % AVATAR_COLORS.length]
  end

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
