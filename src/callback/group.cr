module Callback
  abstract class Group
    abstract def name

    def run(o)
      before.run o
      around.run o
      yield
      around.run o
      after.run o
    end
  end
end
