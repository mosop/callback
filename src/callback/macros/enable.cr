module Callback
  macro enable(klass, namespace = "")
    {% name = namespace == "" ? "callback!" : "#{namespace.id}_callback!" %}

    class ::{{klass.id}}
      macro {{name.id}}
        macro inherited
          ::Callback.__initialize_class {{namespace}}, ::\\{{@type}}, ::\\{{@type.superclass}}
          ::Callback.__inherit_groups ::\\{{@type}}, ::\\{{@type.superclass}}
        end

        ::Callback.__initialize_class {{namespace}}, ::\{{@type}}
      end
    end
  end
end
