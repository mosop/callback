require "../spec_helper"

module CallbackCallbackResultsWikiFeature
  Callback.enable Reference

  class Record
    callback!
    define_callback_group :validate, proc_type: Proc(Bool)

    getter name : String
    getter email : String?

    def initialize(@name, @email = nil)
    end

    on_validate :mosop? do |o|
      o.name == "mosop"
    end

    on_validate do |o|
      !o.email.nil?
    end

    def validate
      run_callbacks_for_validate do |results|
        results.values.all? ? ":)" : ":P"
      end
    end
  end

  it self.name do
    rec = Record.new(name: "mosop")
    rec.validate.should eq ":P"
    results = rec.callback_results_for_validate
    results.values.should eq [true, false]
    results[:mosop?].should be_true
  end
end
