require "../spec_helper"

module CallbackReadmeUsage
  Callback.enable Reference

  class Record
    callback!
    define_callback_group :save

    before :save do
      puts "before"
    end

    around :save do
      puts "around"
    end

    after :save do
      puts "after"
    end

    def save
      run_callbacks :save do
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
      yield
      around
      after\n
      EOS
    end
  end
end
