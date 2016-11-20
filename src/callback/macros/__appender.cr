module Callback
  macro __appender(supergroup_defined, name_node, phase_node, pascal_node, prefix_node, suffix_node, type_node)
    {%
      name = name_node.id
      phase = phase_node.id
      pascal = pascal_node.id
      prefix = prefix_node.id
      suffix = suffix_node.id
      type = type_node.id
      group_class_local = "#{pascal}CallbackGroup_#{name.id}".id
      method = "#{phase}_#{prefix}#{name}".id
      append = "append_#{prefix}callback_for_#{phase}".id
      callbacks_for = "#{prefix}callbacks_for"
    %}

    def self.{{append}}(proc, name)
      {{group_class_local}}.instance.append_{{phase}}(proc, name.to_s)
    end

    {% if supergroup_defined != true %}
      def self.{{method}}(proc)
        {{append}} proc, nil
      end

      def self.{{method}}(name : String, proc)
        {{append}} proc, name
      end

      macro {{method}}(name = nil, &block)
        proc = {{group_class_local}}.block_to_proc \{{block}}
        {{append}} proc, \{{name}}
      end
    {% end %}

    def {{prefix}}callbacks_for_{{name}}
      {{group_class_local}}.instance.procs
    end

    def  {{prefix}}callback_results_for_{{name}}
      {{group_class_local}}.instance.results
    end

    def run_{{prefix}}callbacks_for_{{name}}(*args)
      {{group_class_local}}.instance.run self, *args
    end

    def run_{{prefix}}callbacks_for_{{name}}(*args, &block)
      {{group_class_local}}.instance.run self, *args, &block
    end
  end
end
