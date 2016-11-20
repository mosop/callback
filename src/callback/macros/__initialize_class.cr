module Callback
  macro __initialize_class(namespace_node, type_node, supertype_node = nil)
    {%
      namespace = namespace_node.id
      pascal_node = namespace_node.camelcase
      pascal = pascal_node.id
    %}
    {% if namespace == "".id %}
      {%
        prefix_node = ""
        suffix_node = ""
      %}
    {% else %}
      {%
        prefix_node = "#{namespace.id}_"
        suffix_node = "_#{namespace.id}"
      %}
    {% end %}
    {%
      type_node = type_node.resolve if type_node.class_name == "Path"
      type_node = type_node.name.resolve if type_node.class_name == "Generic"
      supertype_node = supertype_node.resolve if supertype_node.class_name == "Path"
      supertype_node = supertype_node.name.resolve if supertype_node.class_name == "Generic"
    %}
    ::Callback.__initialize_class_default {{pascal_node}}, {{prefix_node}}, {{suffix_node}}, {{type_node}}
    {% if supertype_node == nil %}
      ::Callback.__initialize_base_class {{pascal_node}}, {{prefix_node}}, {{suffix_node}}, {{type_node}}
      ::Callback.__define_define_callback_group {{pascal_node}}, {{prefix_node}}, {{suffix_node}}, {{type_node}}, nil
    {% else %}
      ::Callback.__define_define_callback_group {{pascal_node}}, {{prefix_node}}, {{suffix_node}}, {{type_node}}, {{supertype_node}}
    {% end %}
  end
end
