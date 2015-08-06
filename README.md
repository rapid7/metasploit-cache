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

In a Rails application, Metasploit::Cache acts a
[Rails Engine](http://edgeapi.rubyonrails.org/classes/Rails/Engine.html) and the models are available to the application
just as if they were defined under app/models.  If your Rails appliation needs to modify the models, this can be done
using [metasploit-concern](https://github.com/rapid7/metasploit-concern).

## Seeds

### `Metasploit::Cache::Authority`

Authorities for references (`Metasploit::Cache::Reference#authority`) must be known to prevent typos and so that
reference URLs can be calculated correctly.  When a new authority needs to be supported, such as 

#### Terminology

The metasyntactic variables should be replaced in the example code in this section with their appropriate values.

| Metasyntactic Variable                | Description                                                                                                                                                                    | Example                                          |
|---------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------|
| `<abbreviation>`                      | Abbreviation used as first element of metasploit-framework references                                                                                                          | `CVE`                                            |
| `<titleized-abbreviation>`            | `<abbreviation>` with the first letter capitalized and all others lowercase, so it can be used a ruby Module name                                                              | `Cve`                                            |
| `<summary>`                           | The expanded form of `<abbreviation>`                                                                                                                                          | `Common Vulnerabilities and Expose`              |
| `<url>`                               | The URL to the authority's home page or root URL for their reference database.                                                                                                 | `http://cvedetails.com`                          |
| `<designation-tempalte(designation)>` | Interpolated string that uses `Metasploit::Cache::Reference#designation` to compose a URL to the `Metasploit::Cache::Reference#authority`'s page for the specific designation. | `"http://cvedetails.com/cve/CVE-#{designation}"` |
| `<format-description>`                | Human-readable description of `<designation-template(designation)>` format for spec testing it.                                                                                | `under cve directory`                            |
| `<designation-format>`                | Format using N's, dashes, and literals to show where digits or years appear in designations                                                                                    | `YYYY-NNNN`                                      |
| `<designation-name>`                  | What the authority calls their designations, usually `<foo> ID`                                                                                                                | `CVE ID`                                         |

#### Code

1. Create `lib/metasploit/cache/authority/<authority>.rb`:
   
       # <summary> authority-specific code.
       module Metasploit::Cache::Authority::<captialized-abbreviation>
         # Returns URL to {Metasploit::cache::Reference#designation <designation-name>'s} page.
         #
         # @param designation [String] <designation-format> <designation-name>
         # @return [String] URL
         def self.designation_url(designation)
           "<designation-template(designation)>"
         end
       end
       
2. In `app/models/metasploit/cache/authority.rb`, `autoload` the new module:
   
       autoload <titleized-abbreviation>
       
3. In `lib/metasploit/cache/authority/seed.rb`, in the `ATTRIBUTES` constant add a `Hash` to the `Array`, in order of
   `:abbreviation`:
   
       {
         abbreviation: '<abbreviation>',
         obsolete: false,
         summary: '<summary>'
         url: '<url>'
       }

#### Specs

1. Add a sequence to `spec/factories/metasploit/cache/references.rb`:
   
       sequence(:metasploit_cache_reference_<abbreviation>_designation) { |n|
         n.to_s
       end
   
   If the new authority has designations more complicated than simple, increasing numbers, such as YEAR-NUMBER, then
   simulate that with the sequence:
   
       sequence :metasploit_cache_reference_<abbreviation>_designation { |n|
         number = n % 1000
         year = n / 1000
         
         "#{year}-#{number}"
       }
       
2. In `spec/app/models/metasploit/cache/authority_spec.rb`, in the `'seeds'` context, add the following shared example
   usage, keeping the order by `:abbreviation`:
   
       it_should_behave_like 'Metasploit::Cache::Authority seed',
                             abbreviation: '<abbreviation>',
                             extension_name: 'Metasploit::Cache::Authority::<titleized-abbreviation>',
                             obsolete: false,
                             summary: '<summary>',
                             url: '<url>'

3. Create a new `spec/lib/metasploit/cache/authority/<abbreviation>_spec.rb`:
   
       RSpec.describe Metasploit::Cache::Authority::<captialized-abbreviation> do
         context 'designation_url' do
           subject(:designation_url) {
             described_class.designation_url(designation)
           }
           
           let(:designation) {
             FactoryGirl.generate :metasploit_cache_reference_<abbreviation>_designation
           }
           
           it 'is <format description>' do
             expect(designation_url).to eq("<designation-template(designation)>")
           end
         end
       end                            

4. In `spec/app/models/metasploit/cache/reference_spec.rb`, in the `'derivation'` context, in the `'with authority'`
   context, in the `'with abbreviation'` context, add a new `context` with the `<abbreviation>`:
   
       context '<abbreviation>' do
         let(:abbreviation) {
           '<abbreviation>'
         }
         
         let(:designation) {
           FactoryGirl.generate :metasploit_cache_reference_<abbreviation>_designation
         }
         
         it_should_behave_like 'derives',
                               :url,
                               validates: false
       end


## Testing

### With metasploit-framework

    rm Gemfile.lock
    bundle install
    rake spec

### Without metasploit-framework

    rm Gemfile.lock
    bundle install --without content
    rake spec

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)
