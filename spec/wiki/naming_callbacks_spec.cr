require "../spec_helper"

module CallbackNamingCallbacksWikiFeature
  Callback.enable Reference

  class Record
    callback!
    define_callback_group :validate

    after_validate :smiley do |rec|
      rec.smile
    end

    def smile
      puts ":)"
    end
  end

  it name do
    Stdio.capture do |io|
      Record.callbacks_for(:validate)[:smiley].call(Record.new)
      io.out.gets_to_end.should eq ":)\n"
    end
  end
end
