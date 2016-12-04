require "../spec_helper"

module CallbackUsingDynamicGroupsWikiFeature
  class Emitter
    Callback.enable
    define_callback_group :event

    on_event do
      puts "static"
    end
  end

  it name do
    Stdio.capture do |io|
      emitter = Emitter.new
      emitter.on_event do
        puts "dynamic"
      end
      emitter.run_callbacks_for_event {}
      io.out.gets_to_end.should eq "static\ndynamic\n"
    end
  end
end
