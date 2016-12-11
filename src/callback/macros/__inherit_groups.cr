module Callback
  macro __inherit_groups(pascal_node, upcase_node, prefix_node, suffix_node, type_node)
    {%
      pascal = pascal_node.id
      upcase = upcase_node.id
      prefix = prefix_node.id
      suffix = suffix_node.id
      type_node = type_node.resolve if type_node.class_name == "Path"
      type_node = type_node.name.resolve if type_node.class_name == "Generic"
      supertype_node = type_node.superclass
      supertype = supertype_node.id
      supertype_id = supertype.split("(")[0].split("::").join("_").id
      supersnake_type_id = supertype_id.underscore
      superupcase_type_id = supersnake_type_id.upcase
      supercustom_const_prefix = "#{superupcase_type_id}__#{prefix.upcase.id}CALLBACK_CUSTOM_".id
      superauto_const_prefix = "#{superupcase_type_id}__#{prefix.upcase.id}CALLBACK_AUTO_".id
      const_suffix = "_FOR__".id
      supercustom = "#{supercustom_const_prefix}PROC_ARG_INDEXES#{const_suffix}"
      superauto = "#{superauto_const_prefix}PROC_ARG_INDEXES#{const_suffix}"
      found = %w()
    %}
    {% for c, i in supertype_node.constants %}
      {% if c.id.stringify.starts_with?(supercustom) %}
        {% name = c.id.split("__")[-1].downcase %}
        {% found << name.stringify %}
        class ::{{type_node.id}}
          define_callback_group :{{name.id}}, inherit: true
        end
      {% end %}
    {% end %}
    {% for c, i in supertype_node.constants %}
      {% if c.id.stringify.starts_with?(superauto) %}
        {% name = c.id.split("__")[-1].downcase %}
        {% unless found.includes?(name.stringify) %}
          class ::{{type_node.id}}
            define_callback_group :{{name.id}}, inherit: true
          end
        {% end %}
      {% end %}
    {% end %}
  end
end
