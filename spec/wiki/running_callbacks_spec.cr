require "../spec_helper"

module CallbackRunningCallbacksWikiFeature
  Callback.enable Reference

  module AccessingAnInstanceInCallbacks
    class Record
      callback!
      define_callback_group :save

      before_save do |o|
        o.validate
      end

      def validate
        puts "validate"
      end

      def save
        run_callbacks_for_save do
          puts "save"
        end
      end
    end

    it name do
      rec = Record.new
      Stdio.capture do |io|
        rec.save
        io.out.gets_to_end.should eq <<-EOS
        validate
        save\n
        EOS
      end
    end
  end
end
