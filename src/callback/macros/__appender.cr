module Callback
  macro __appender(name_node, phase_node, pascal_node, prefix_node, suffix_node, type_node)
    {%
      name = name_node.id
      phase = phase_node.id
      pascal = pascal_node.id
      prefix = prefix_node.id
      suffix = suffix_node.id
      type = type_node.id
      group_class_local = "#{pascal}CallbackGroup_#{name.id}".id
      method = "#{phase}_#{prefix}#{name}".id
    %}

    def self.{{method}}(proc)
      {{group_class_local}}.instance.{{phase}} << proc
    end

    macro {{method}}(&block)
      proc = {{group_class_local}}.block_to_proc \{{block}}
      {{method}} proc
    end

    def run_{{prefix}}callbacks_for_{{name}}(*args)
      {{group_class_local}}.instance.run self, *args
    end

    def run_{{prefix}}callbacks_for_{{name}}(*args, &block)
      {{group_class_local}}.instance.run self, *args, &block
    end
  end
end
