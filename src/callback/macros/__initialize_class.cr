module Callback
  macro __initialize_class(namespace, type, supertype = nil)
    {% type_node = type.resolve if type.class_name == "Path" %}
    {% type_node = type.name.resolve if type.class_name == "Generic" %}
    {% supertype_node = supertype.resolve if supertype.class_name == "Path" %}
    {% supertype_node = supertype.name.resolve if supertype.class_name == "Generic" %}
    {% if supertype == nil %}
      ::Callback.__initialize_class2 {{namespace}}, ::{{type_node}}, nil
    {% elsif supertype_node.type_vars.size > 0 %}
      ::Callback.__initialize_class {{namespace}}, ::{{type_node}}, ::{{supertype_node.superclass}}
    {% else %}
      ::Callback.__initialize_class2 {{namespace}}, ::{{type_node}}, ::{{supertype_node}}
    {% end %}
  end

  macro __initialize_class2(namespace, type_node, supertype_node)
    {%
      if namespace.id == "".id
        prefix = ""
        suffix = ""
      else
        prefix = "#{namespace.id}_"
        suffix = "_#{namespace.id}"
      end %}
    {%
      type_node = type_node.resolve
      supertype_node = supertype_node.resolve if supertype_node != nil
      pascal = namespace.camelcase
    %}

    class ::{{type_node}}
      {% if supertype_node == nil %}
        ::Callback.__define_callback_group {{pascal}}, {{prefix}}, {{suffix}}, ::{{type_node}}, nil
      {% else %}
        ::Callback.__define_callback_group {{pascal}}, {{prefix}}, {{suffix}}, ::{{type_node}}, ::{{supertype_node}}
      {% end %}
    end
  end
end
