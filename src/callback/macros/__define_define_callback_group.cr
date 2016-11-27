module Callback
  macro __define_define_callback_group(pascal_node, upcase_node, prefix_node, suffix_node, type_node, supertype_node)
    {%
      type_node = type_node.resolve if type_node.class_name == "Path"
      type_node = type_node.name.resolve if type_node.class_name == "Generic"
      supertype_node = supertype_node.resolve if supertype_node.class_name == "Path"
      supertype_node = supertype_node.name.resolve if supertype_node.class_name == "Generic"
    %}

    class ::{{type_node.id}}
      # Defines a new callback group.
      #
      # The inherit attribute is for internal use only. Do not set any value.
      macro define_{{prefix_node.id}}callback_group(name, proc_type = ::Proc(::Nil), inherit = nil)
        ::Callback.__define_callback_group(\{{name}}, \{{proc_type}}, \{{inherit}}, {{pascal_node}}, {{upcase_node}}, {{prefix_node}}, {{suffix_node}}, {{type_node}}, {{supertype_node}})
      end
    end
  end
end
