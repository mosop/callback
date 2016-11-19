require "./callback/*"

module Callback
  class Type
    macro inherited
      {%
        type = @type.id.split("::")[0..-2].join("::")
      %}

      alias Type = ::{{type.id}}
    end
  end

  macro enable(klass, namespace = "")
    {% name = namespace == "" ? "callback!" : "#{namespace.id}_callback!" %}

    class ::{{klass.id}}
      macro {{name.id}}(namespace = {{namespace}})
        macro inherited
          ::Callback.initialize_callback_class \{{namespace}}, ::\\\{{@type}}, ::\\\{{@type.superclass}}
        end

        ::Callback.initialize_callback_class \{{namespace}}, ::\{{@type}}
      end
    end
  end

  macro initialize_callback_class(namespace, type, supertype = nil)
    {%
      if namespace == ""
        prefix = ""
        suffix = ""
      else
        prefix = "#{namespace.id}_".id
        suffix = "_#{namespace.id}".id
      end %}

    {%
      type = type.resolve.id
      supertype = supertype.resolve.id unless supertype == nil
    %}

    {%
      if supertype == nil
        supergroup_class = "Callback::Group".id
      else
        supergroup_class = "#{supertype}::#{namespace.camelcase.id}CallbackGroup".id
      end %}

    {%
      group_class = "#{type}::#{namespace.camelcase.id}CallbackGroup".id
      define_callback_group = "define_#{prefix.id}callback_group".id
      callback_groups = "#{prefix.id}callback_groups".id
      run_callbacks = "run_#{prefix.id}callbacks".id
      before = "before#{suffix.id}".id
      around = "around#{suffix.id}".id
      after = "after#{suffix.id}".id
     %}

    class ::{{group_class}} < ::{{supergroup_class}}
      class Set < ::Callback::Set(::{{type}})
        alias Proc = ::Proc(::{{type}}, ::Nil)

        @procs = [] of Proc

        def <<(proc : Proc)
          @procs << proc
        end

        def run(o : ::{{type}})
          @procs.each do |proc|
            proc.call o
          end
        end
      end

      @supergroup : ::{{supergroup_class}}?
      getter name : String

      def initialize(@supergroup, @name)
      end

      @before : Set?
      def before
        @before ||= Set.new
      end

      @around : Set?
      def around
        @around ||= Set.new
      end

      @after : Set?
      def after
        @after ||= Set.new
      end
    end

    @@{{callback_groups}} : ::Hash(::String, ::{{group_class}})?
    def self.{{callback_groups}}
      {% if supertype == nil %}
        @@{{callback_groups}} ||= {} of ::String => ::{{group_class}}
      {% else %}
        @@{{callback_groups}} = ({} of ::String => ::{{group_class}}).tap do |h|
          super.each do |k, v|
            h[k] = ::{{group_class}}.new(v, k)
          end
        end
      {% end %}
    end

    def self.{{define_callback_group}}(name)
      name = name.to_s
      {{callback_groups}}[name] = ::{{group_class}}.new(nil, name)
    end

    def self.{{before}}(name, proc : ::{{group_class}}::Set::Proc)
      {{callback_groups}}[name.to_s].before << proc
    end

    macro {{before}}(name, &block)
      {{before}} \{{name}}, ->(o : ::{{type}}) {
        \{% if block.args.size > 0 %}
          o.tap \{{block}}
        \{% else %}
          \{{block.body}}
        \{% end %}
        nil
      }
    end

    def self.{{around}}(name, proc : ::{{group_class}}::Set::Proc)
      {{callback_groups}}[name.to_s].around << proc
    end

    macro {{around}}(name, &block)
      {{around}} \{{name}}, ->(o : ::{{type}}) {
        \{% if block.args.size > 0 %}
          o.tap \{{block}}
        \{% else %}
          \{{block.body}}
        \{% end %}
        nil
      }
    end

    def self.{{after}}(name, proc : ::{{group_class}}::Set::Proc)
      {{callback_groups}}[name.to_s].after << proc
    end

    macro {{after}}(name, &block)
      {{after}} \{{name}}, ->(o : ::{{type}}) {
        \{% if block.args.size > 0 %}
          o.tap \{{block}}
        \{% else %}
          \{{block.body}}
        \{% end %}
        nil
      }
    end

    def {{run_callbacks}}(name)
      self.class.{{callback_groups}}[name.to_s].run(self) do
        yield
      end
    end
  end
end
