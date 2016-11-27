require "../spec_helper"

module CallbackFixRelativeBlockTypeShouldBeResolvedFeature
  class Outer
    def foo
      puts ":)"
    end

    class Obj
      Callback.enable
      define_callback_group :foo, proc_type: Proc(Outer, Nil)

      on_foo do |obj, outer|
        outer.foo
      end
    end

    it name do
      Stdio.capture do |io|
        Obj.new.run_callbacks_for_foo(Outer.new) {}
        io.out.gets_to_end.should eq ":)\n"
      end
    end
  end
end
