module Callback
  macro enable(namespace = "")
    {%
      nsid = namespace.id
      pascal_node = namespace.camelcase
    %}
    {% if nsid == "".id %}
      {%
        prefix_node = ""
        suffix_node = ""
      %}
    {% else %}
      {%
        prefix_node = "#{nsid}_"
        suffix_node = "_#{nsid}"
      %}
    {% end %}

    # Defines a new callback group.
    #
    # This macro is automatically defined by the Crystal Callback library.
    macro define_{{prefix_node.id}}callback_group(name, proc_type = ::Proc(::Nil))
      ::Callback.__define_callback_group(false, \{{name}}, \{{proc_type}}, {{pascal_node}}, {{prefix_node}}, {{suffix_node}}, ::\{{@type}})
    end

    # Inherits an existing callback group that is defined in its ancestor class.
    #
    # This macro is automatically defined by the Crystal Callback library.
    macro inherit_{{prefix_node.id}}callback_group(name, proc_type = ::Proc(::Nil))
      ::Callback.__define_callback_group(true, \{{name}}, \{{proc_type}}, {{pascal_node}}, {{prefix_node}}, {{suffix_node}}, ::\{{@type}})
    end
  end
end
