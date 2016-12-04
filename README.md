# Crystal Callback

A Crystal library for defining and invoking callbacks.

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

class Record
  Callback.enable
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

rec = Record.new
rec.save
```

This prints:
```
before
around
on
yield
around
after
```

For more detail, see [Wiki](https://github.com/mosop/callback/wiki)

## Release Notes

See [Releases](https://github.com/mosop/callback/releases).
