module Callback
  macro __initialize_base_class(pascal_node, prefix_node, suffix_node, type_node)
    {%
      pascal = pascal_node.id
      prefix = prefix_node.id
      type_node = type_node.resolve if type_node.class_name == "Path"
      type_node = type_node.name.resolve if type_node.class_name == "Generic"
      type = type_node.id
      instance_mod = "#{pascal}CallbackInstance".id
    %}

    class ::{{type}}
      getter {{prefix}}callback_results = {} of ::String => ::Callback::ResultSet
    end
  end
end
