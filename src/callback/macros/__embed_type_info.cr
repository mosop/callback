module Callback
  macro __embed_type_info(proc_type, type_node, superproc_id, inherit, template, pre_call = "", post_call = "", pre_def = "", post_def = "")
    {% if inherit %}
      {% if superproc_id.class_name == "Path" %}
        ::Callback.__embed_type_info(nil, {{type_node}}, {{superproc_id.resolve.id}}, true, {{template}}, {{pre_call}}, {{post_call}}, {{pre_def}}, {{post_def}})
      {% else %}
        {%
          a = superproc_id.id.split(",")
          s = a[1..-1].join(",")
          s = "::Proc(" + a[1..-1].join(",")
        %}
        ::Callback.__embed_type_info({{s.id}}, {{type_node}}, nil, false, {{template}}, {{pre_call}}, {{post_call}}, {{pre_def}}, {{post_def}})
      {% end %}
    {% else %}
      {%
        type_node = type_node.resolve if type_node.class_name == "Path"
        type_node = type_node.name.resolve if type_node.class_name == "Generic"
      %}
      {% if type_node.type_vars.size > 0 %}
        ::Callback.__embed_type_info({{proc_type}}, {{type_node.superclass}}, nil, false, {{template}}, {{pre_call}}, {{post_call}}, {{pre_def}}, {{post_def}})
      {% else %}
        {%
          type = type_node.id
          count_of_args = proc_type.type_vars.size
          raise "excess of 64 arguments" if count_of_args > 64
          args_node = "_1 _2 _3 _4 _5 _6 _7 _8 _9 _10 _11 _12 _13 _14 _15 _16 _17 _18 _19 _20 _21 _22 _23 _24 _25 _26 _27 _28 _29 _30 _31 _32 _33 _34 _35 _36 _37 _38 _39 _40 _41 _42 _43 _44 _45 _46 _47 _48 _49 _50 _51 _52 _53 _54 _55 _56 _57 _58 _59 _60 _61 _62 _63 _64".split(" ")[0..count_of_args-1]
          args_with_types_node = ["_1 : ::#{type}"]
          types_node = ["::#{type}"]
          casted_args_node = ["_1.as(::#{type})"]
        %}
        {% for e, i in args_node %}
          {% if i != 0 %}
            {%
              type_var = proc_type.type_vars[i-1].id
              type_var = type_var.gsub(/\(/, "(::")
              type_var = type_var.gsub(/,\s*/, ", ::")
              type_var = type_var.gsub(/^:+/, "")
              type_var = type_var.gsub(/::::/, "::")
              args_with_types_node << "#{e.id} : ::#{type_var.id}"
              types_node << "::#{type_var.id}"
              casted_args_node << "#{e.id}.as(::#{type_var.id})"
            %}
          {% end %}
        {% end %}
        {% if args_node.size == 1 %}
          {%
            args_without_instance_node = %w()
            args_with_types_without_instance_node = %w()
            types_without_instance_node = %w()
            casted_args_without_instance_node = %w()
          %}
        {% else %}
          {%
            args_without_instance_node = args_node[1..-1]
            args_with_types_without_instance_node = args_with_types_node[1..-1]
            types_without_instance_node = types_node[1..-1]
            casted_args_without_instance_node = casted_args_node[1..-1]
          %}
        {% end %}
        {%
          _args = args_node.map{|i| "#{i.id}"}.join(", ")
          _args_with_types = args_with_types_node.map{|i| "#{i.id}"}.join(", ")
          _types = types_node.map{|i| "#{i.id}"}.join(", ")
          _casted_args = casted_args_node.map{|i| "#{i.id}"}.join(", ")
          _args_without_instance = args_without_instance_node.map{|i| "#{i.id}"}.join(", ")
          _args_with_types_without_instance = args_with_types_without_instance_node.map{|i| "#{i.id}"}.join(", ")
          _types_without_instance = types_without_instance_node.map{|i| "#{i.id}"}.join(", ")
          _casted_args_without_instance = casted_args_without_instance_node.map{|i| "#{i.id}"}.join(", ")
          a = %w()
          a = a + [pre_call] unless pre_call.id.empty?
          a = a + [_args_without_instance] unless _args_without_instance.empty?
          a = a + [post_call] unless post_call.id.empty?
          _call_args_without_instance = a.join(", ")
          a = %w()
          a = a + [pre_def] unless pre_def.id.empty?
          a = a + [_args_with_types_without_instance] unless _args_with_types_without_instance.empty?
          a = a + [post_def] unless post_def.id.empty?
          _def_args_without_instance = a.join(", ")
          a = %w()
          a = a + [pre_call] unless pre_call.id.empty?
          a = a + [_casted_args_without_instance] unless _casted_args_without_instance.empty?
          a = a + [post_call] unless post_call.id.empty?
          _call_casted_args_without_instance = a.join(", ")
          _result_type = proc_type.type_vars[-1].stringify
          _nil = _result_type.id.gsub(/:/, "").id == "Nil".id ? "nil" : ""
          _any_result_type = _nil.empty? ? _result_type : "_"
          a = proc_type.id.split("(")
          _proc_type = "::Proc(::#{type_node.id}, " + a[1..-1].join("(")
          s = template.gsub(/\$\(ARGS\)/, _args)
          s = s.gsub(/\$\(ARGS_WITH_TYPES\)/, _args_with_types)
          s = s.gsub(/\$\(TYPES\)/, _types)
          s = s.gsub(/\$\(DEF_ARGS_WITHOUT_INSTANCE\)/, _def_args_without_instance)
          s = s.gsub(/\$\(CALL_ARGS_WITHOUT_INSTANCE\)/, _call_args_without_instance)
          s = s.gsub(/\$\(CALL_CASTED_ARGS_WITHOUT_INSTANCE\)/, _call_casted_args_without_instance)
          s = s.gsub(/\$\(RESULT_TYPE\)/, _result_type)
          s = s.gsub(/\$\(NIL\)/, _nil)
          s = s.gsub(/\$\(ANY_RESULT_TYPE\)/, _any_result_type)
          s = s.gsub(/\$\(PROC_TYPE\)/, _proc_type)
        %}
        {{s.id}}
      {% end %}
    {% end %}
  end
end
