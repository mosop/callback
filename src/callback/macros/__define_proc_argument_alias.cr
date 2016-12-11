module Callback
  macro __define_proc_argument_alias(inherit, prefix, suffix, types)
    {% for e, i in types %}
    # :nodoc:
      {% if i == 0 %}
        alias {{prefix.id}}ProcArg{{suffix.id}}{{i+1}} = ::{{types[i].id}}
      {% else %}
        alias {{prefix.id}}ProcArg{{suffix.id}}{{i+1}} = {{types[i].id}}
      {% end %}
    {% end %}
  end
end
