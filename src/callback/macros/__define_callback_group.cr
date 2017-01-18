module Callback
  macro __define_callback_group(inherit, name_node, proc_type, pascal_node, prefix_node, suffix_node, type_node)
    {%
      name = name_node.id
      pascal = pascal_node.id
      prefix = prefix_node.id
      suffix = suffix_node.id
      type_node = type_node.resolve if type_node.class_name == "Path"
      type_node = type_node.name.resolve if type_node.class_name == "Generic"
      type = type_node.id
      type_id = type.split("(")[0].split("::").join("_").id
      snake_type_id = type_id.underscore
      run_method_prefix = "run_#{prefix}callbacks_for_#{name}".id
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
    {%
      # count_of_args = arg_types.size
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
      {% unless inherit %}
        # Returns the callback results.
        getter {{prefix}}callback_results = {} of ::String => ::Callback::ResultSet({{result_type}})
      {% end %}

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
        rs = ::Callback::ResultSet({{result_type}}).new
        @{{prefix}}callback_results[{{name.stringify}}] = rs
        rs
      end

      def {{prefix}}callback_results_for_{{name}}
        (@{{prefix}}callback_results[{{name.stringify}}] ||= ::Callback::ResultSet({{result_type}}).new).as(::Callback::ResultSet({{result_type}}))
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
            # superrun_method = "#{superrun_method_prefix}__#{phase}".id
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

          {{callbacks_var}} = ::Array(::Proc({{arg_types.splat}}, {{result_type}})).new
          def {{_self}}{{callbacks}}
            {{callbacks_var}}
          end

          {{callback_names_var}} = {} of ::Pointer(::Void) => ::String
          def {{_self}}{{callback_names}}
            {{callback_names_var}}
          end

          def {{_self}}{{append_method}}(proc : ::Proc({{arg_types.splat}}, {{result_type}}), name)
            {{callbacks_var}} << proc
            {{callback_names_var}}[proc.pointer] = name.to_s if name
          end

          def {{_self}}{{phase_method}}(proc : ::Proc({{arg_types.splat}}, {{result_type}}))
            {{append_method}} proc, nil
          end

          def {{_self}}{{phase_method}}(name, proc : ::Proc({{arg_types.splat}}, {{result_type}}))
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

          # :nodoc:
          def {{_self}}{{run_method}}(results, *args)
            {% if scope == :instance %}
              ::{{type}}.{{run_method}} results, *args
              {{run_method}}2 results, *args
            {% else %}
              {% if inherit %}
                super
              {% end %}
              ::{{type}}.{{run_method}}2 results, *args
            {% end %}
          end

          # :nodoc:
          def {{_self}}{{run_method}}2(results, {{args.splat}})
            {% for arg, i in args %}
              {{arg}} = {{arg}}.as({{arg_types[i]}})
            {% end %}
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
