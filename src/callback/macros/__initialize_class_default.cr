module Callback
  macro __initialize_class_default(pascal_node, prefix_node, suffix_node, type_node)
    {%
      pascal = pascal_node.id
      prefix = prefix_node.id
      type_node = type_node.resolve if type_node.class_name == "Path"
      type_node = type_node.name.resolve if type_node.class_name == "Generic"
      type = type_node.id
    %}
  end
end
