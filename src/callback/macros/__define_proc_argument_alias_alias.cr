module Callback
  macro __define_proc_argument_alias_alias(prefix, suffix, *elements)
    {% for e, i in elements %}
    # :nodoc:
    alias ProcArgumentType{{suffix.id}}{{i+1}} = {{prefix.id}}ProcArgumentType{{suffix.id}}{{i+1}}
    {% end %}
  end
end
