module Callback
  macro __define_callback_group(pascal_node, prefix_node, suffix_node, type_node, supertype_node)
    {%
      pascal = pascal_node.id
      prefix = prefix_node.id
      suffix = suffix_node.id
      type = type_node.id
      supertype = supertype_node == nil ? nil : supertype_node.id
    %}

    class ::{{type}}
      macro define_{{prefix}}callback_group(name_node, proc_type = ::Proc(::Nil))
        \{%
          name = name_node.id
          group_class_local = "{{pascal}}CallbackGroup_#{name}".id
          group_class = "{{type}}::#{group_class_local}".id
          type = @type.id
          count_of_args = proc_type.type_vars.size
          raise "excess of 64 arguments" if count_of_args > 64
          args = "_1 _2 _3 _4 _5 _6 _7 _8 _9 _10 _11 _12 _13 _14 _15 _16 _17 _18 _19 _20 _21 _22 _23 _24 _25 _26 _27 _28 _29 _30 _31 _32 _33 _34 _35 _36 _37 _38 _39 _40 _41 _42 _43 _44 _45 _46 _47 _48 _49 _50 _51 _52 _53 _54 _55 _56 _57 _58 _59 _60 _61 _62 _63 _64".split(" ")[0..count_of_args-1]
          args_with_types = ["_1 : ::#{type}"]
        %}
        \{% for e, i in args %}
          \{% if i != 0 %}
            \{%
              type_var = proc_type.type_vars[i-1]
              type_var = type_var.id.gsub(/\(/, "(::")
              type_var = type_var.id.gsub(/,\s*/, ", ::")
              type_var = type_var.id.gsub(/^:+/, "")
              type_var = type_var.id.gsub(/::::/, "::")
              args_with_types << "_#{i.id} : ::#{type_var.id}"
            %}
          \{% end %}
        \{% end %}
        \{%
          args = args.map{|i| "#{i.id}"}.join(", ").id
          args_with_types = args_with_types.map{|i| "#{i.id}"}.join(", ").id
        %}
        {% if supertype == nil %}
          \{%
            supertype_node = nil
            supertype = nil
            supergroup_defined = false
            supergroup_class = "Callback::Group".id
          %}
        {% else %}
          \{%
            supertype_node = @type.superclass
            supertype = supertype_node.id
            supergroup_defined = supertype_node.constants.includes?(group_class_local)
            supergroup_class = supergroup_defined == true ? "#{supertype}::#{group_class_local}".id : "Callback::Group".id
          %}
        {% end %}

        class ::{{type}}
          class \{{group_class_local}} < ::\{{supergroup_class}}
            \{% if supergroup_defined != true %}
              ::Callback.__globalize_generic_type \{{proc_type}}, {{type}}, prefix: "alias ProcType = "
            \{% end %}

            class Phase
              @procs = [] of ::\{{group_class}}::ProcType

              def <<(proc : ::\{{group_class}}::ProcType)
                @procs << proc
              end

              def run(\{{args_with_types}})
                @procs.each do |proc|
                  proc.call \{{args}}
                end
              end
            end

            \{% if supergroup_defined != true %}
              alias AbstractInstanceType = \{{group_class_local}}
              @@instance : ::\{{group_class}}?
              @supergroup : ::\{{supergroup_class}}?
              @before : Phase?
              @around : Phase?
              @after : Phase?
              @on : Phase?

              def before
                @before ||= Phase.new
              end

              def around
                @around ||= Phase.new
              end

              def after
                @after ||= Phase.new
              end

              def on
                @on ||= Phase.new
              end

              macro block_to_proc(&block)
                ->(\{{args_with_types}}) {
                  ::Callback.__yield(\{{args}}) \\{{block}}
                  \{% if proc_type.type_vars[-1].id.gsub(/:/, "").id == "Nil".id %}
                    nil
                  \{% end %}
                }
              end
            \{% end %}

            def self.abstract_instance
              @@instance ||= ::\{{group_class}}.new.as(AbstractInstanceType)
            end

            def self.instance
              abstract_instance.as(::\{{group_class}})
            end

            def root?
              @supergroup.nil?
            end

            def supergroup
              \{% if supergroup_defined == true %}
                ::\{{supergroup_class}}.instance
              \{% else %}
                nil
              \{% end %}
            end

            def run(\{{args_with_types}})
              run_before \{{args}}
              run_around \{{args}}
              run_on \{{args}}
              result = yield \{{args}}
              run_around \{{args}}
              run_after \{{args}}
              result
            end

            def run_before(\{{args_with_types}})
              \{% if supergroup_defined == true %}
                supergroup.run_before \{{args}}
              \{% end %}
              before.run \{{args}}
            end

            def run_around(\{{args_with_types}})
              \{% if supergroup_defined == true %}
                supergroup.run_around \{{args}}
              \{% end %}
              around.run \{{args}}
            end

            def run_after(\{{args_with_types}})
              \{% if supergroup_defined == true %}
                supergroup.run_after \{{args}}
              \{% end %}
              after.run \{{args}}
            end

            def run_on(\{{args_with_types}})
              \{% if supergroup_defined == true %}
                supergroup.run_on \{{args}}
              \{% end %}
              on.run \{{args}}
            end
          end

          ::Callback.__appender \{{name_node}}, :before, {{pascal_node}}, {{prefix_node}}, {{suffix_node}}, ::{{type}}
          ::Callback.__appender \{{name_node}}, :around, {{pascal_node}}, {{prefix_node}}, {{suffix_node}}, ::{{type}}
          ::Callback.__appender \{{name_node}}, :after, {{pascal_node}}, {{prefix_node}}, {{suffix_node}}, ::{{type}}
          ::Callback.__appender \{{name_node}}, :on, {{pascal_node}}, {{prefix_node}}, {{suffix_node}}, ::{{type}}
        end
      end

      macro run_{{prefix}}callbacks(name, *args, &block)
        \{% group_class_local = "{{pascal}}CallbackGroup_#{name.id}".id %}
        \{% if args.size > 0 %}
          \{{group_class_local}}.instance.run(self, \{{args}}) \{{block}}
        \{% else %}
          \{{group_class_local}}.instance.run(self) \{{block}}
        \{% end %}
      end
    end
  end
end
