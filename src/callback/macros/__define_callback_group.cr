module Callback
  macro __define_callback_group(inherit, name_node, proc_type, pascal_node, upcase_node, prefix_node, suffix_node, type_node)
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
      type = type_node.id
      type_id = type.split("(")[0].split("::").join("_").id
      snake_type_id = type_id.underscore
      upcase_type_id = snake_type_id.upcase
      custom_alias_prefix = "#{type_id}__#{pascal}CallbackCustom".id
      auto_alias_prefix = "#{type_id}__#{pascal}CallbackAuto".id
      alias_suffix = "For#{pascal_name}".id
      custom_const_prefix = "#{upcase_type_id}__#{prefix.upcase.id}CALLBACK_CUSTOM_".id
      auto_const_prefix = "#{upcase_type_id}__#{prefix.upcase.id}CALLBACK_AUTO_".id
      const_suffix = "_FOR__#{upcase_name}".id
      alias_prefix = inherit ? auto_alias_prefix : custom_alias_prefix
      const_prefix = inherit ? auto_const_prefix : custom_const_prefix
      proc_alias = "#{alias_prefix}Proc#{alias_suffix}".id
      result_alias = "#{alias_prefix}ProcResult#{alias_suffix}".id
      count_of_args_const = "#{const_prefix}COUNT_OF_PROC_ARGS#{const_suffix}".id
      arg_indexes_const = "#{const_prefix}PROC_ARG_INDEXES#{const_suffix}".id
      run_method_prefix = "#{snake_type_id}__run_#{prefix}callbacks_for_#{name}".id
      class_const = "#{const_prefix}Class"
      supertype_node = type_node.superclass
      supertype = supertype_node.id
      supertype_id = supertype.split("(")[0].split("::").join("_").id
      supersnake_type_id = supertype_id.underscore
      superupcase_type_id = supersnake_type_id.upcase
      supercustom_alias_prefix = "#{supertype_id}__#{pascal}CallbackCustom".id
      superauto_alias_prefix = "#{supertype_id}__#{pascal}CallbackAuto".id
      supercustom_const_prefix = "#{superupcase_type_id}__#{prefix.upcase.id}CALLBACK_CUSTOM_".id
      superauto_const_prefix = "#{superupcase_type_id}__#{prefix.upcase.id}CALLBACK_AUTO_".id
      superrun_method_prefix = "#{supersnake_type_id}__run_#{prefix}callbacks_for_#{name}".id
    %}
    {% if superarg_indexes = supertype_node.constant("#{supercustom_const_prefix}PROC_ARG_INDEXES#{const_suffix}") %}
      {%
        superalias_prefix = supercustom_alias_prefix
        superconst_prefix = supercustom_const_prefix
      %}
    {% elsif superarg_indexes = supertype_node.constant("#{superauto_const_prefix}PROC_ARG_INDEXES#{const_suffix}") %}
      {%
        superalias_prefix = superauto_alias_prefix
        superconst_prefix = superauto_const_prefix
      %}
    {% else %}
      {%
        supertype_node = nil
        supertype = nil
      %}
    {% end %}

    {% if inherit %}
      {%
        double_colon = "::".id
        result_type = supertype_node.constant("#{superalias_prefix}ProcResult#{alias_suffix}")
        arg_types = [type_node]
      %}
      {% for e, i in superarg_indexes %}
        {% if i > 0 %}
          {%
            arg_types << "::#{supertype}::#{superalias_prefix}ProcArg#{alias_suffix}#{i+1}".id
          %}
        {% end %}
      {% end %}
    {% else %}
      {%
        double_colon = "".id
        result_type = proc_type.type_vars.last
        arg_types = [type_node]
      %}
      {% if proc_type.type_vars.size >= 2 %}
        {% for arg, i in proc_type.type_vars[0..-2] %}
          {%
            arg_types << arg
          %}
        {% end %}
      {% end %}
    {% end %}
    {%
      count_of_args = arg_types.size
      arg_indexes = %w()
      args = %w()
      typed_args = %w()
      is_nil = result_type == ::Nil
    %}
    {% for arg, i in arg_types %}
      {%
        arg_indexes << i
        args << "_#{i+1}".id
        typed_args << "_#{i+1} : #{arg}".id
      %}
    {% end %}

    class ::{{type}}
      {% unless supertype %}
        # Returns the callback results.
        getter {{prefix}}callback_results = {} of ::String => ::Callback::ResultSet({{result_type}})
      {% end %}

      # :nodoc:
      alias {{proc_alias}} = ::Proc({{double_colon}}{{arg_types.splat}}, {{double_colon}}{{result_type}})
      ::Callback.__define_proc_argument_alias {{inherit}}, {{alias_prefix}}, {{alias_suffix}}, {{arg_types}}
      # :nodoc:
      alias {{result_alias}} = {{double_colon}}{{result_type}}
      # :nodoc:
      {{count_of_args_const}} = {{count_of_args}}
      # :nodoc:
      {{arg_indexes_const}} = {{arg_indexes}}

      def run_{{prefix}}callbacks_for_{{name}}(*args)
        results = renew_{{prefix}}callback_results_for_{{name}}
        {{run_method_prefix}}__before results, self, *args
        {{run_method_prefix}}__around results, self, *args
        {{run_method_prefix}}__on results, self, *args
        result = yield results
        {{run_method_prefix}}__around results, self, *args
        {{run_method_prefix}}__after results, self, *args
        result
      end

      # :nodoc:
      def renew_{{prefix}}callback_results_for_{{name}}
        rs = ::Callback::ResultSet({{result_alias}}).new
        @{{prefix}}callback_results[{{name.stringify}}] = rs
        rs
      end

      def {{prefix}}callback_results_for_{{name}}
        (@{{prefix}}callback_results[{{name.stringify}}] ||= ::Callback::ResultSet({{result_alias}}).new).as(::Callback::ResultSet({{result_alias}}))
      end

      {% for phase, i in %w(before around after on) %}
        {% for scope, j in [:class, :instance] %}
          {%
            phase = phase.id
            phase_method = "#{phase}_#{prefix}#{name}".id
            append_method = "append_#{prefix}callback_for_#{name}__#{phase}".id
            callbacks = "#{snake_type_id}__#{prefix}callbacks_for_#{name}__#{phase}".id
            callback_names = "#{snake_type_id}__#{prefix}callback_names_for_#{name}__#{phase}".id
            run_method = "#{run_method_prefix}__#{phase}".id
            superrun_method = "#{superrun_method_prefix}__#{phase}".id
          %}
          {% if scope == :instance %}
            {%
              _self = "".id
              callbacks_var = "@#{callbacks}".id
              callback_names_var = "@#{callback_names}".id
            %}
          {% else %}
            {%
              _self = "self.".id
              callbacks_var = "@@#{callbacks}".id
              callback_names_var = "@@#{callback_names}".id
            %}
          {% end %}

          {{callbacks_var}} = ::Array({{proc_alias}}).new
          def {{_self}}{{callbacks}}
            {{callbacks_var}}
          end

          {{callback_names_var}} = {} of ::Pointer(::Void) => ::String
          def {{_self}}{{callback_names}}
            {{callback_names_var}}
          end

          def {{_self}}{{append_method}}(proc : {{proc_alias}}, name)
            {{callbacks_var}} << proc
            {{callback_names_var}}[proc.pointer] = name.to_s if name
          end

          def {{_self}}{{phase_method}}(proc : {{proc_alias}})
            {{append_method}} proc, nil
          end

          def {{_self}}{{phase_method}}(name, proc : {{proc_alias}})
            {{append_method}} proc, name
          end

          def {{_self}}{{phase_method}}(name = nil, &block : {{arg_types.splat}} -> {{is_nil ? "_".id : result_type}})
            proc = ->({{typed_args.splat}}) {
              block.call {{args.splat}}
              {% if is_nil %}
                nil
              {% end %}
            }
            {{append_method}} proc, name
          end

          def {{_self}}{{run_method}}(results, *args)
            {% if scope == :instance %}
              ::{{type}}.{{run_method}} results, *args
              {{run_method}}2 results, *args
            {% else %}
              {% if supertype %}
                ::{{supertype}}.{{superrun_method}} results, *args
              {% end %}
              {{run_method}}2 results, *args
            {% end %}
          end

          def {{_self}}{{run_method}}2(results, {{args.splat}})
            {{callbacks_var}}.each do |proc|
              result = proc.call({{args.splat}})
              results.all << result
              results.{{phase}} << result
              if name = {{callback_names_var}}[proc.pointer]?
                results[name] = result
              end
            end
          end
        {% end %}
      {% end %}
    end
  end
end
