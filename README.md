# Crystal Callback

A Crystal library for defining callbacks.

[![Build Status](https://travis-ci.org/mosop/callback.svg?branch=master)](https://travis-ci.org/mosop/callback)

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  callback:
    github: mosop/callback
```

## Usage

```crystal
require "callback"

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

rec = Record.new
rec.save
```

This prints:
```
before
around
yield
around
after
```

For more detail, see [Wiki](https://github.com/mosop/callback/wiki)

## Contributing

1. Fork it ( https://github.com/mosop/callback/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request
