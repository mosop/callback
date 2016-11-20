require "../spec_helper"

module CallbackSpecifyingWikiFeature
  Callback.enable Reference

  class AgeOfMajority
    callback!
    define_callback_group :check, proc_type: Proc(Int32, String)

    on_check :smiley do |o, i|
      i >= o.age ? ":)" : ":P"
    end

    getter age : Int32

    def initialize(@age)
    end
  end

  it name do
    aom = AgeOfMajority.new(18)
    Stdio.capture do |io|
      aom.run_callbacks_for_check(25) do |results|
        puts results[:smiley]
      end
      aom.run_callbacks_for_check(15) do |results|
        puts results[:smiley]
      end
      io.out.gets_to_end.should eq <<-EOS
        :)
        :P\n
        EOS
    end
  end
end
