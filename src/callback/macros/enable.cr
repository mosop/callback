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

    macro {{prefix}}_enable_callback
      macro inherited
        ::Callback.__initialize_class {{namespace}}, ::\\{{@type}}, ::\\{{@type.superclass}}
        ::Callback.__inherit_groups ::\\{{@type}}, ::\\{{@type.superclass}}
      end

      ::Callback.__initialize_class {{namespace}}, ::\{{@type}}
    end

    {{prefix}}_enable_callback
  end
end
