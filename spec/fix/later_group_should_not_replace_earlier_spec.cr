require "../spec_helper"

module CallbackFixLaterGroupShouldNotReplaceEarlierFeature
  class Obj
    Callback.enable
    define_callback_group :foo
    define_callback_group :bar

    on_foo do
      puts "foo"
    end

    on_bar do
      puts "bar"
    end
  end

  it name do
    Stdio.capture do |io|
      Obj.new.run_callbacks_for_foo {}
      io.out.gets_to_end.should eq "foo\n"
    end
  end
end
