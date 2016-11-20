require "../spec_helper"

module CallbackInheritingCallbacksWikiFeature
  Callback.enable Reference

  class Super
    callback!
    define_callback_group :super

    before_super do
      puts "super"
    end
  end

  class Sub < Super
    before_super do
      puts "super in sub"
    end
  end

  it name do
    Stdio.capture do |io|
      Super.new.run_callbacks_for_super {}
      Sub.new.run_callbacks_for_super {}
      io.out.gets_to_end.should eq <<-EOS
      super
      super
      super in sub\n
      EOS
    end
  end
end
