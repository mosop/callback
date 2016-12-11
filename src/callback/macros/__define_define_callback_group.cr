module Callback
  macro __define_define_callback_group(pascal_node, upcase_node, prefix_node, suffix_node, type_node)
    class ::{{type_node.id}}
      # Defines a new callback group.
      #
      # The inherit attribute is for internal use only. Do not set any value.
      macro define_{{prefix_node.id}}callback_group(name, proc_type = ::Proc(::Nil), inherit = nil)
        ::Callback.__define_callback_group(\{{inherit}}, \{{name}}, \{{proc_type}}, {{pascal_node}}, {{upcase_node}}, {{prefix_node}}, {{suffix_node}}, ::\{{@type}})
      end
    end
  end
end
