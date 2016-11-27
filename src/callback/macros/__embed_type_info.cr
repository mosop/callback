module Callback
  macro __embed_type_info(proc_type, type, supergroup, count_of_args, is_nil, inherit, template, alias_prefix = nil, alias_suffix = nil)
    {%
      type = type.resolve if type.class_name == "Path"
      type = type.name.resolve if type.class_name == "Generic"
    %}
    {% if inherit %}
      {%
        count_of_args = count_of_args.resolve
        is_nil = is_nil.resolve
      %}
    {% else %}
      {%
        count_of_args = proc_type.type_vars.size
        raise "excess of 64 arguments" if count_of_args > 64
      %}
    {% end %}
    {%
      args = "_1 _2 _3 _4 _5 _6 _7 _8 _9 _10 _11 _12 _13 _14 _15 _16 _17 _18 _19 _20 _21 _22 _23 _24 _25 _26 _27 _28 _29 _30 _31 _32 _33 _34 _35 _36 _37 _38 _39 _40 _41 _42 _43 _44 _45 _46 _47 _48 _49 _50 _51 _52 _53 _54 _55 _56 _57 _58 _59 _60 _61 _62 _63 _64".split(" ")[0..count_of_args-1]
    %}
    {% if inherit %}
      {%
        _result_type = "::#{supergroup}::ProcResultType"
        _nil = is_nil ? "nil" : ""
        _is_nil = is_nil ? "true" : "false"
        _any_result_type = is_nil ? "_" : _result_type
        types = %w()
      %}
      {% for e, i in args %}
        {%
          types << "::#{supergroup}::ProcArgumentType#{alias_suffix}#{i+1}".id
        %}
      {% end %}
    {% else %}
      {%
        _result_type = proc_type.type_vars[-1].id.stringify
        _nil = _result_type.id.gsub(/:/, "").id == "Nil".id ? "nil" : ""
        _is_nil = _nil == "nil" ? "true" : "false"
        _any_result_type = _nil.empty? ? _result_type : "_"
        types = ["::#{type}".id]
      %}
      {% if args.size >= 2 %}
        {%
          types = types + proc_type.type_vars[0..-2].map{|i| i.id}
        %}
      {% end %}
    {% end %}
    {%
      _proc_type = "::Proc(#{types.join(", ").id}, #{_result_type.id})"
      _args = args.join(", ")
      _types = types.join(", ")
      _count_of_args = count_of_args.stringify
      s = template.gsub(/\$\(ARGS\)/, _args)
      s = s.gsub(/\$\(TYPES\)/, _types)
      s = s.gsub(/\$\(RESULT_TYPE\)/, _result_type)
      s = s.gsub(/\$\(NIL\)/, _nil)
      s = s.gsub(/\$\(IS_NIL\)/, _is_nil)
      s = s.gsub(/\$\(ANY_RESULT_TYPE\)/, _any_result_type)
      s = s.gsub(/\$\(PROC_TYPE\)/, _proc_type)
      s = s.gsub(/\$\(COUNT_OF_ARGS\)/, _count_of_args)
    %}
    {% if alias_prefix %}
      {%
        alias_prefix = alias_prefix.id
        alias_suffix = alias_suffix.id
        aliases = %w()
        args_with_aliases = %w()
      %}
      {% for e, i in args %}
        {%
          al = "::#{type}::#{alias_prefix}ProcArgumentType#{alias_suffix}#{i+1}".id
          aliases << al
          args_with_aliases << "_#{i+1} : #{al}".id
        %}
      {% end %}
      {%
        _aliases = aliases.join(", ")
        _args_with_aliases = args_with_aliases.join(", ")
        s = s.gsub(/\$\(ALIASES\)/, _aliases)
        s = s.gsub(/\$\(ARGS_WITH_ALIASES\)/, _args_with_aliases)
      %}
    {% end %}
    {{s.id}}
  end
end
