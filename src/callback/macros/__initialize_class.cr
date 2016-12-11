module Callback
  macro __initialize_class(is_base, namespace_node, type_node)
    {%
      namespace = namespace_node.id
      pascal_node = namespace_node.camelcase
      upcase_node = namespace_node.upcase
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
    %}
    ::Callback.__initialize_class_default {{pascal_node}}, {{upcase_node}}, {{prefix_node}}, {{suffix_node}}, {{type_node}}
    {% if is_base %}
      ::Callback.__initialize_base_class {{pascal_node}}, {{upcase_node}}, {{prefix_node}}, {{suffix_node}}, {{type_node}}
      ::Callback.__define_define_callback_group {{pascal_node}}, {{upcase_node}}, {{prefix_node}}, {{suffix_node}}, {{type_node}}
    {% else %}
      ::Callback.__inherit_groups {{pascal_node}}, {{upcase_node}}, {{prefix_node}}, {{suffix_node}}, {{type_node}}
    {% end %}
  end
end
