require "../spec_helper"

module CallbackFixForceGlobalNemespace
  module Ns
    class Base
      Callback.enable

      macro inherited
        define_callback_group :foo, proc_type: ::Proc(::Nil)
      end
    end
  end

  module CallbackFixForceGlobalNemespace
    class Klass < Ns::Base
    end
  end

  it name do
    CallbackFixForceGlobalNemespace::Klass.new.run_callbacks_for_foo {}
  end
end
