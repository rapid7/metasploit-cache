# Metasploit::Cache [![Build Status](https://travis-ci.org/rapid7/metasploit-cache.svg?branch=master)](https://travis-ci.org/rapid7/metasploit-cache)[![Code Climate](https://codeclimate.com/github/rapid7/metasploit-cache.png)](https://codeclimate.com/github/rapid7/metasploit-cache)[![Coverage Status](https://img.shields.io/coveralls/rapid7/metasploit-cache.svg)](https://coveralls.io/r/rapid7/metasploit-cache)[![Dependency Status](https://gemnasium.com/rapid7/metasploit-cache.svg)](https://gemnasium.com/rapid7/metasploit-cache)[![Gem Version](https://badge.fury.io/rb/metasploit-cache.svg)](http://badge.fury.io/rb/metasploit-cache)[![Inline docs](http://inch-ci.org/github/rapid7/metasploit-cache.svg?branch=master)](http://inch-ci.org/github/rapid7/metasploit-cache)[![PullReview stats](https://www.pullreview.com/github/rapid7/metasploit-cache/badges/master.svg?)](https://www.pullreview.com/github/rapid7/metasploit-cache/reviews/master)

Cache of Metasploit Module metadata, architectures, platforms, references, and authorities that can persist between
reboots of metasploit-framework and Metasploit applications

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'metasploit-cache'
```

And then execute:

    $ bundle

**This gem's `Rails::Engine` is not required automatically.** You'll need to also add the following to your `config/application.rb`:

    require 'metasploit/cache/engine'

Or install it yourself as:

    $ gem install metasploit-cache

## Usage

TODO: Write usage instructions here

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)
