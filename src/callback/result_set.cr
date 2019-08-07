module Callback
  class ResultSet(T)
    include Enumerable({String, T})

    getter before = [] of T
    getter around = [] of T
    getter on = [] of T
    getter after = [] of T
    getter all = [] of T
    getter named = {} of String => T

    def []?(name)
      @named[name.to_s]?
    end

    def [](name)
      @named[name.to_s]
    end

    def []=(name, value)
      @named[name.to_s] = value
    end

    def has?(name)
      named.has_key?(name.to_s)
    end

    def each(&block : T -> _)
      named.each do |_, v|
        yield v
      end
    end
  end
end
