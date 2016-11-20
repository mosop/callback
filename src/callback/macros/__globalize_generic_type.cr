module Callback
  macro __globalize_generic_type(type, first_types = %w(), prefix = "")
    {% first_types = [first_types] unless first_types.class_name == "ArrayLiteral" %}
    {% type = type.id.gsub(/\(/, "(::") %}
    {% type = type.id.gsub(/,\s*/, ", ::") %}
    {% if first_types.size > 0 %}
      {%
        a = type.split("(")
        a1 = "#{first_types.map{|i| "::#{i.id}"}.join(", ").id}, #{a[1].id}"
        type = ([a[0], a1] + a[2..-1]).map{|i| i.id}.join("(")
      %}
    {% end %}
    {% type = type.id.gsub(/^:+/, "") %}
    {% type = type.id.gsub(/::::/, "::") %}
    {{prefix.id}}::{{type}}
  end
end
