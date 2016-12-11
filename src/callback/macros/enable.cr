module Callback
  macro enable(namespace = "")
    {% if namespace == "" %}
      {%
        prefix = "".id
      %}
    {% else %}
      {%
        prefix = "#{namespace.id}_".id
      %}
    {% end %}

    # :nodoc:
    macro {{prefix}}_enable_callback
      macro inherited
        ::Callback.__initialize_class false, {{namespace}}, ::\\{{@type}}
      end

      ::Callback.__initialize_class true, {{namespace}}, ::\{{@type}}
    end

    {{prefix}}_enable_callback
  end
end
