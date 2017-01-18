require "../spec_helper"

module CallbackFixHandlingAbstractClass
  abstract class Abstract
    Callback.enable
    define_callback_group :foo

    on_foo do
      puts "abstract"
    end
  end

  class Concrete1 < Abstract
    inherit_callback_group :foo

    on_foo do
      puts "concrete1"
    end
  end

  class Concrete2 < Abstract
    inherit_callback_group :foo

    on_foo do
      puts "concrete2"
    end
  end

  it name do
    Stdio.capture do |io|
      a = [Concrete1.new, Concrete2.new]
      a.each do |i|
        i.run_callbacks_for_foo {}
      end
      io.out.gets_to_end.should eq "abstract\nconcrete1\nabstract\nconcrete2\n"
    end
  end
end
