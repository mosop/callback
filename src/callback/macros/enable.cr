module Callback
  macro enable(klass, namespace = "")
    {% name = namespace == "" ? "callback!" : "#{namespace.id}_callback!" %}

    class ::{{klass.id}}
      macro {{name.id}}
        macro inherited
          \\{% if @type.type_vars.size == 0 %}
            ::Callback.__initialize_class {{namespace}}, ::\\{{@type}}, ::\\{{@type.superclass}}
          \\{% end %}
          \\{% group_prefix = "{{namespace.id}}CallbackGroup_" %}
          \\{% for c, i in @type.superclass.constants %}
            \\{% if c.id.stringify.starts_with?(group_prefix) %}
              \\{% a = c.id.split("_") %}
              \\{% group_name = a[1..-1].join("_").id %}
              define_callback_group :\\{{group_name}}
            \\{% end %}
          \\{% end %}
        end

        ::Callback.__initialize_class {{namespace}}, ::\{{@type}}
      end
    end
  end
end
