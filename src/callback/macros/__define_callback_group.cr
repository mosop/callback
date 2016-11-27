module Callback
  macro __define_callback_group(name_node, proc_type, inherit, pascal_node, upcase_node, prefix_node, suffix_node, type_node, supertype_node, custom_groups = ::Callback::Groups::Custom, auto_groups = ::Callback::Groups::Auto)
    {%
      name = name_node.id
      pascal_name = name_node.id.camelcase.id
      upcase_name = name_node.id.upcase.id
      pascal = pascal_node.id
      upcase = upcase_node.id
      prefix = prefix_node.id
      suffix = suffix_node.id
      type_node = type_node.resolve if type_node.class_name == "Path"
      type_node = type_node.name.resolve if type_node.class_name == "Generic"
      supertype_node = supertype_node.resolve if supertype_node.class_name == "Path"
      supertype_node = supertype_node.name.resolve if supertype_node.class_name == "Generic"
      custom_groups = custom_groups.resolve
      auto_groups = auto_groups.resolve
      type = type_node.id
      mod_id = type.split("(")[0].split("::").join("_").id
      group_class_l = "#{mod_id}__#{name}".id
      group_class = inherit ? "Callback::Groups::Auto::#{group_class_l}".id : "Callback::Groups::Custom::#{group_class_l}".id
      phase_class = "#{group_class}::Phase".id
      proc_class = "#{group_class}::Proc".id
      proc_set_class = "#{group_class}::ProcSet".id
      result_set_class = "#{group_class}::ResultSet".id
      custom_alias_prefix = "#{pascal}CallbackCustom".id
      auto_alias_prefix = "#{pascal}CallbackAuto".id
      alias_prefix = inherit ? auto_alias_prefix : custom_alias_prefix
      alias_suffix = "For#{pascal_name}".id
      proc_alias = "#{type}::#{alias_prefix}ProcType#{alias_suffix}".id
      proc_result_alias = "#{type}::#{alias_prefix}ProcResultType#{alias_suffix}".id
      custom_const_prefix = "#{prefix.upcase.id}CALLBACK_CUSTOM_".id
      auto_const_prefix = "#{prefix.upcase.id}CALLBACK_AUTO_".id
      const_prefix = inherit ? auto_const_prefix : custom_const_prefix
      const_suffix = "_FOR_#{upcase_name}".id
      group_instance_mod = "Callback::Groups::Instance::#{group_class_l}".id
      group_class_mod = "Callback::Groups::Class::#{group_class_l}".id
    %}

    {% if supertype_node == nil %}
      {%
        supertype = nil
        supergroup_defined = false
        supergroup_class = nil
        superproc_class = nil
        supercount_of_proc_args = nil
        superis_nil = nil
      %}
    {% else %}
      {%
        supertype = supertype_node.id
        supermod_id = supertype.split("(")[0].split("::").join("_").id
        supergroup_class_l = "#{supermod_id}__#{name}".id
      %}
      {% if custom_groups.constants.includes?(supergroup_class_l) %}
        {%
          supergroup_defined = true
          supergroup_class = "Callback::Groups::Custom::#{supergroup_class_l}".id
          superproc_class = "#{supergroup_class}::Proc".id
          supercount_of_proc_args = "#{supertype}::#{custom_const_prefix}COUNT_OF_PROC_ARGUMENTS#{const_suffix}".id
          superis_nil = "#{supertype}::#{custom_const_prefix}PROC_RESULT_TYPE_IS_NIL#{const_suffix}".id
        %}
      {% elsif auto_groups.constants.includes?(supergroup_class_l) %}
        {%
          supergroup_defined = true
          supergroup_class = "Callback::Groups::Auto::#{supergroup_class_l}".id
          supercount_of_proc_args = "#{supertype}::#{auto_const_prefix}COUNT_OF_PROC_ARGUMENTS#{const_suffix}".id
          superis_nil = "#{supertype}::#{auto_const_prefix}PROC_RESULT_TYPE_IS_NIL#{const_suffix}".id
        %}
      {% else %}
        {%
          supergroup_defined = false
          supergroup_class = "Callback::Group".id
          superproc_class = "Callback::Proc".id
          supercount_of_proc_args = nil
          superis_nil = nil
        %}
      {% end %}
    {% end %}

    class ::{{group_class}} < ::Callback::Group
    end


    class ::{{type}}
      ::Callback.__embed_type_info({{proc_type}}, {{type_node}}, {{supergroup_class}}, {{supercount_of_proc_args}}, {{superis_nil}}, {{inherit}}, alias_prefix: {{alias_prefix}}, alias_suffix: {{alias_suffix}}, template: <<-EOS
        alias {{alias_prefix}}ProcType{{alias_suffix}} = $(PROC_TYPE)
        ::Callback.__define_proc_argument_alias {{alias_prefix}}, {{alias_suffix}}, {{inherit}}, $(TYPES)
        alias {{alias_prefix}}ProcResultType{{alias_suffix}} = $(RESULT_TYPE)
        {{const_prefix}}COUNT_OF_PROC_ARGUMENTS{{const_suffix}} = $(COUNT_OF_ARGS)
        {{const_prefix}}PROC_RESULT_TYPE_IS_NIL{{const_suffix}} = $(IS_NIL)
        class ::{{group_class}}
          alias ProcType = ::{{type}}::{{alias_prefix}}ProcType{{alias_suffix}}
          ::Callback.__define_proc_argument_alias_alias ::{{type}}::{{alias_prefix}}, {{alias_suffix}}, $(ARGS)
          alias ProcResultType = ::{{type}}::{{alias_prefix}}ProcResultType{{alias_suffix}}
          COUNT_OF_PROC_ARGUMENTS = ::{{type}}::{{const_prefix}}COUNT_OF_PROC_ARGUMENTS{{const_suffix}}
          PROC_RESULT_TYPE_IS_NIL = ::{{type}}::{{const_prefix}}PROC_RESULT_TYPE_IS_NIL{{const_suffix}}
        end
        EOS
      )
    end


    class ::{{group_class}}
      class Proc
        @proc : ::{{proc_alias}}

        def initialize(@proc, name)
          @name = name.to_s if name
        end

        def proc
          @proc.as(::{{proc_alias}})
        end

        @name : ::String?
        def name?
          @name
        end

        def name
          @name.as(::String)
        end

        ::Callback.__embed_type_info({{proc_type}}, {{type_node}}, {{supergroup_class}}, {{supercount_of_proc_args}}, {{superis_nil}}, {{inherit}}, alias_prefix: {{alias_prefix}}, alias_suffix: {{alias_suffix}}, template: <<-EOS
          def call($(ARGS))
            @proc.call $(ARGS)
          end
          EOS
        )
      end

      class ResultSet < ::Callback::ResultSet
        getter values = [] of ::{{proc_result_alias}}
        getter named = {} of ::String => ::{{proc_result_alias}}

        def [](name)
          named[name.to_s]
        end
      end

      class ProcSet
        @group : ::{{group_class}}

        def initialize(@group)
        end

        getter named = {} of ::String => ::{{proc_class}}

        def [](name)
          name = name.to_s
          find_named(name) unless named[name]?
          named[name]
        end

        def []?(name)
          name = name.to_s
          find_named(name) unless named[name]?
          named[name]?
        end

        def find_named(name)
          if proc = @group.find_named_proc(name)
            named[name] = proc
          end
        end
      end

      class Phase
        @procs = [] of ::{{proc_class}}

        def <<(proc : ::{{proc_class}})
          @procs << proc
        end

        def run(results, *args)
          @procs.each do |proc|
            result = proc.call(*args)
            results.values << result
            results.named[proc.name] = result if proc.name?
          end
        end
      end

      @@instance : ::{{group_class}}?
      @before : ::{{phase_class}}?
      @around : ::{{phase_class}}?
      @after : ::{{phase_class}}?
      @on : ::{{phase_class}}?
      @procs : ::{{proc_set_class}}?

      def before
        @before ||= ::{{phase_class}}.new
      end

      def around
        @around ||= ::{{phase_class}}.new
      end

      def after
        @after ||= ::{{phase_class}}.new
      end

      def on
        @on ||= ::{{phase_class}}.new
      end

      def procs
        @procs ||= ::{{proc_set_class}}.new(self)
      end

      def self.instance
        @@instance ||= ::{{group_class}}.new
      end

      def root?
        @supergroup.nil?
      end

      def supergroup
        {% if supergroup_defined %}
          ::{{supergroup_class}}.instance
        {% else %}
          nil
        {% end %}
      end

      def append_before(proc : ::{{proc_alias}}, name)
        proc = ::{{proc_class}}.new(proc, name)
        before << proc
        named_procs[proc.name] = proc if proc.name?
      end

      def append_around(proc : ::{{proc_alias}}, name)
        proc = ::{{proc_class}}.new(proc, name)
        around << proc
        named_procs[proc.name] = proc if proc.name?
      end

      def append_after(proc : ::{{proc_alias}}, name)
        proc = ::{{proc_class}}.new(proc, name)
        after << proc
        named_procs[proc.name] = proc if proc.name?
      end

      def append_on(proc : ::{{proc_alias}}, name)
        proc = ::{{proc_class}}.new(proc, name)
        on << proc
        named_procs[proc.name] = proc if proc.name?
      end

      def run(results, *args, &block)
        run_before results, *args
        run_around results, *args
        run_on results, *args
        result = yield
        run_around results, *args
        run_after results, *args
        result
      end

      def run_before(results, *args)
        {% if supergroup_defined %}
          supergroup.run_before results, *args
        {% end %}
        before.run results, *args
      end

      def run_around(results, *args)
        {% if supergroup_defined %}
          supergroup.run_around results, *args
        {% end %}
        around.run results, *args
      end

      def run_after(results, *args)
        {% if supergroup_defined %}
          supergroup.run_after results, *args
        {% end %}
        after.run results, *args
      end

      def run_on(results, *args)
        {% if supergroup_defined %}
          supergroup.run_on results, *args
        {% end %}
        on.run results, *args
      end

      @named_procs = {} of ::String => ::{{proc_class}}
      def named_procs
        @named_procs
      end

      def find_named_proc(name)
        named_procs[name]? || begin
          {% if supergroup_defined %}
            supergroup.find_named_proc(name)
          {% else %}
            nil
          {% end %}
        end
      end
    end

    module ::{{group_instance_mod}}
      def run_{{prefix}}callbacks_for_{{name}}(*args)
        results = renew_{{prefix}}callback_results_for_{{name}}
        ::{{group_class}}.instance.run results, self, *args do
          yield results
        end
      end

      def renew_{{prefix}}callback_results_for_{{name}}
        rs = ::{{result_set_class}}.new
        @{{prefix}}callback_results[{{name.stringify}}] = rs
        rs
      end

      def {{prefix}}callback_results_for_{{name}}
        (@{{prefix}}callback_results[{{name.stringify}}] ||= ::{{result_set_class}}.new).as(::{{result_set_class}})
      end
    end

    module ::{{group_class_mod}}
      {% for phase, i in %w(before around after on) %}
        {%
          phase = phase.id
          phase_method = "#{phase}_#{prefix}#{name}".id
          append_method = "append_#{prefix}callback_for_#{phase}_#{name}".id
        %}

        def {{append_method}}(proc : ::{{proc_alias}}, name)
          ::{{group_class}}.instance.append_{{phase}}(proc, name)
        end

        def {{phase_method}}(proc : ::{{proc_alias}})
          {{append_method}} proc, nil
        end

        def {{phase_method}}(name, proc : ::{{proc_alias}})
          {{append_method}} proc, name
        end

        ::Callback.__embed_type_info({{proc_type}}, {{type_node}}, {{supergroup_class}}, {{supercount_of_proc_args}}, {{superis_nil}}, {{inherit}}, alias_prefix: {{alias_prefix}}, alias_suffix: {{alias_suffix}}, template: <<-EOS
          def {{phase_method}}(name = nil, &block : $(ALIASES) -> $(ANY_RESULT_TYPE))
            proc = ->($(ARGS_WITH_ALIASES)) {
              block.call $(ARGS)
              $(NIL)
            }
            {{append_method}} proc, name
          end
          EOS
        )
      {% end %}

      def {{prefix}}callbacks_for_{{name}}
        ::{{group_class}}.instance.procs
      end
    end

    class ::{{type}}
      include ::{{group_instance_mod}}
      extend ::{{group_class_mod}}
    end
  end
end
