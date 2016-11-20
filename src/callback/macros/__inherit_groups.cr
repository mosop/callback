module Callback
  macro __inherit_groups(type_node, supertype_node, custom_groups = ::Callback::Groups::Custom, auto_groups = ::Callback::Groups::Auto)
    {%
      type_node = type_node.resolve if type_node.class_name == "Path"
      type_node = type_node.name.resolve if type_node.class_name == "Generic"
      supertype_node = supertype_node.resolve if supertype_node.class_name == "Path"
      supertype_node = supertype_node.name.resolve if supertype_node.class_name == "Generic"
      custom_groups = custom_groups.resolve
      auto_groups = auto_groups.resolve
      supertype = supertype_node.id
      supertype_mod = supertype.split("(")[0].split("::").join("_").id
      group_prefix = "#{supertype_mod}__"
      found = %w()
    %}
    {% for c, i in custom_groups.constants %}
      {% if c.id.stringify.starts_with?(group_prefix) %}
        {% name = c.id.split("__")[-1] %}
        {% found = found + [name.stringify] %}
        class ::{{type_node.id}}
          define_callback_group :{{name.id}}, inherit: true
        end
      {% end %}
    {% end %}
    {% for c, i in auto_groups.constants %}
      {% if c.id.stringify.starts_with?(group_prefix) %}
        {% name = c.id.split("__")[-1] %}
        {% unless found.includes?(name.stringify) %}
          class ::{{type_node.id}}
            define_callback_group :{{name.id}}, inherit: true
          end
        {% end %}
      {% end %}
    {% end %}
  end
end
