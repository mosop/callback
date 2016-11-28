require "../spec_helper"

module CallbackFixProcArgumentTypeIsAutomaticallyReplacedWithSubclassFeature
  abstract class Super
    Callback.enable
    define_callback_group :foo
  end

  class Sub1 < Super
    on_foo do |o|
      o.foo
    end

    def foo
      puts ":)"
    end
  end

  class Sub2 < Super
  end

  it name do
    Stdio.capture do |io|
      Sub1.new.run_callbacks_for_foo {}
      io.out.gets_to_end.should eq ":)\n"
    end
  end
end
