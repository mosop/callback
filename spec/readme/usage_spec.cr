require "../spec_helper"

module CallbackReadmeUsage
  Callback.enable Reference

  class Record
    callback!
    define_callback_group :save

    before_save do
      puts "before"
    end

    around_save do
      puts "around"
    end

    after_save do
      puts "after"
    end

    on_save do
      puts "on"
    end

    def save
      run_callbacks_for_save do
        puts "yield"
      end
    end
  end

  it name do
    rec = Record.new
    Stdio.capture do |io|
      rec.save
      io.out.gets_to_end.should eq <<-EOS
      before
      around
      on
      yield
      around
      after\n
      EOS
    end
  end
end
