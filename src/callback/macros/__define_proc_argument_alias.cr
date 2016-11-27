module Callback
  macro __define_proc_argument_alias(prefix, suffix, inherit, *types)
    {% for e, i in types %}
    # :nodoc:
    alias {{prefix.id}}ProcArgumentType{{suffix.id}}{{i+1}} = {{types[i].id}}
    {% end %}
  end
end
