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


### `Metasploit::Cache::Platform`

Platforms for Metasploit Modules and exploit Metasploit Module targets must be known to prevent typos and assist with
automated compatibility between Metasploit Modules.

#### Terminology

The metasyntactic variables should be replace d in the example code in this section with their appropriate values.

| Metasyntactic Variable   | Description                                                                                                        | Example      |
|--------------------------|--------------------------------------------------------------------------------------------------------------------|--------------|
| `<relative-name>`        | The name of the platform relative to its parent.  For root platforms, this is the same as `<fully-qualified-name>` | `10`         |
| `<parent-relative-name>` | The `<relative-name>` for the parent platform.                                                                     | `Windows`    |
| `<fully-qualified-name>` | The `<relative-name>` of each level joined together.                                                               | `Windows 10` |

#### Code

1. In `lib/metasploit/cache/platform/seed.rb`, add an entry to `RELATIVE_NAME_TREE`.  Each level is in alphabetical
   order.  Leaf nodes point to `nil` to end the branch.
   
   If adding a platform without any versions, just put it at the first level
   
       RELATIVE_NAME_TREE = {
         # ...
         '<relative-name>' => nil
         # ...
       }
   
   If adding a version or variant to a pre-existing platform, nest it under the parent platform
   
      RELATIVE_NAME_TREE = {
        # ...
        '<parent-relative-name>' => {
          `<relative-name>' => nil
        }
        # ...
      }

#### Specs

1. In `app/models/metasploit/cache/platform_spec.rb`, in the `'.fully_qualified_names'` context, add an example for the
   `<fully-qualified-name>` in alphabetical order
   
       RSpec.describe Metasploit::Cache::Platform do
         # ...
         context '.fully_qualified_names' do
           # ...
           it { is_expected.to include '<fully-qualified-name>' }
           # ...
         # ...
       end

##### For Root platforms

NOTE: Do these steps only when adding a root platform.

1. In `app/models/metasploit/cache/platform_spec.rb`, in the `'root_fully_qualified_name_set'` context, add an example
   for the `<fully-qualified-name>` in alphabetical order.
   
       RSpec.describe Metasploit::Cache::Platform do
         # ...
         context 'root_fully_qualified_name_set' do
           # ...
           it { is_expected.to include '<fully-qualified-name>' }
           # ...
         # ...
       end
       
2. In `lib/metasploit/cache/platform/seed_spec.rb`, in `'CONSTANTS'` context, in `'RELATIVE_NAME_TREE'` context, add
   an example for the `<fully-qualified-name>` in alphabetical order.
   
       RSpec.describe Metasploit::Cache::Platform::Seed do
         context 'CONSTANTS' do
           context 'RELATIVE_NAME_TREE' do
             # ...
             it { is_expected.to include('<fully-qualified-name>') }
             # ...
           end
         end
         # ...
       end

##### For Nested Platforms

NOTE: Do these steps only when adding non-root, nested platforms.

1. In `lib/metasploit/cache/platform/seed_spec.rb`, in `'CONSTANTS'` context, in `'RELATIVE_NAME_TREE'` context, add
   an example for the `<relative-name>` in alphabetical order.
   
       RSpec.describe Metasploit::Cache::Platform::Seed do
         context 'CONSTANTS' do
           context 'RELATIVE_NAME_TREE' do
             # ...
             context "['<parent-relative-name>']" do
               # ...
               it { is_expected.to include('<relative-name>') }
               # ...
             end
             # ...
           end
         end
         # ...
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

## Validating metasploit-framework Metasploit Modules

The `metasploit-cache` binary can be used to check that Metasploit Modules from a given type directory can be loaded
into the cache and that individual Metasploit Modules can be loaded out of the cache using just their Metasploit Module
full name.

### Loading

`metasploit-cache load` can be used to load a `Metasploit::Cache::Module::Path` and one or all type directories under
it.

#### Prepare test environment


```sh
rm Gemfile.lock
rm -rf .bundle
bundle install --without sqlite3
rake db:drop db:create db:migrate
rake app:db:test:load
```

#### Load entire `Metasploit::Cache::Module::Path`

```ruby
export METASPLOIT_FRAMEWORK=`bundle show metasploit-framework`
cd spec/dummy
time metasploit-cache load ${METASPLOIT_FRAMEWORK}/modules \
                           --database-yaml config/database.yml \
                           --environment test \
                           --include ${METASPLOIT_FRAMEWORK} \
                                     ${METASPLOIT_FRAMEWORK}/app/validators \
                           --require metasploit/framework \
                                     metasploit/framework/executable_path_validator \
                                     metasploit/framework/file_path_validator \
                           --gem metasploit-framework \
                           --logger-severity INFO \
                           --name modules 2>&1 | tee metasploit-cache-load.log
```

You want to pipe to `tee` so that you can record the log in addition to seeing the output.

The expected time to complete is ~3 minutes (`129.09s user 10.99s system 79% cpu 2:55.31 total` from the `time` output).

#### Faster loading with concurrency

The cache can be constructed faster using threading (`--concurrent`), but SQLite3 had a lot of failures due to how it
implements transaction isolation using locks, which could cause reads to fail once an EXCLUSIVE lock was acquired for a
concurrent write, so `--concurrent` is `false` by default.

```ruby
export METASPLOIT_FRAMEWORK=`bundle show metasploit-framework`
cd spec/dummy
time metasploit-cache load ${METASPLOIT_FRAMEWORK}/modules \
                           --concurrent \
                           --database-yaml config/database.yml \
                           --environment test \
                           --include ${METASPLOIT_FRAMEWORK} \
                                     ${METASPLOIT_FRAMEWORK}/app/validators \
                           --require metasploit/framework \
                                     metasploit/framework/executable_path_validator \
                                     metasploit/framework/file_path_validator \
                           --gem metasploit-framework \
                           --logger-severity INFO \
                           --name modules 2>&1 | tee metasploit-cache-load.log
```

Because MRI is only single threaded when CPU bound, concurrent, doesn't speed up the load much
(`129.66s user 17.74s system 92% cpu 2:39.27 total`).  The speed can be made faster if you lower the transaction
isolation level is certain places in the code, but that can lead to inconsistent database state.

#### Load only a single type directory

If you want to load a single type of Metasploit Module, such as exploits, you can restrict the load to a one (or more
type directories) with `--only-type-directories`.

Loading only `exploits`:

```ruby
export METASPLOIT_FRAMEWORK=`bundle show metasploit-framework`
cd spec/dummy
time metasploit-cache load ${METASPLOIT_FRAMEWORK}/modules \
                           --database-yaml config/database.yml \
                           --environment test \
                           --include ${METASPLOIT_FRAMEWORK} \
                                     ${METASPLOIT_FRAMEWORK}/app/validators \
                           --require metasploit/framework \
                                     metasploit/framework/executable_path_validator \
                                     metasploit/framework/file_path_validator \
                           --gem metasploit-framework \
                           --logger-severity INFO \
                           --name modules
                           --only-type-directories exploits 2>&1 | tee metasploit-cache-load-exploits.log
```

#### Common Warnings from Log

Warnings do not prevent a Metasploit Module from being added to the cache, but instead indicate when the raw values from
the Metasploit Module were converted to a canonical representation in the cache.  The warnings should be corrected as
they imply missing or invalid metadata that can be systematically correctly, but is still wrong and may be uncacheable
in the future.

##### `Deprecated, non-canonical architecture abbreviation ("mips") converted to canonical abbreviations (["mipsbe", "mipsle"])`

`mips` is not a supported `Metasploit::Cache::Architecture#abbreviation` because there are multiple MIPS architectures.
`mips` is assumed to be 32-bit (and not 64-bit), but the endianness can be not inferred, so `mips` is converted to
`mipsbe` (MIPS Big-Endian) and `mipsle` (MIPS Little-Endian).

To get rid of the warning, change `'mips'` in the Metasploit Module file to `['mipsbe', 'miple']`.  The file is tagged
in the log as the 3rd `[ ]` tag:

```
[2015-11-11 12:34:54.916][WARN][/Users/limhoff/.rvm/gems/ruby-2.2.3@metasploit-cache/bundler/gems/metasploit-framework-1bfa84b37bca/modules/encoders/generic/none.rb]  Deprecated, non-canonical architecture abbreviation ("mips") converted to canonical abbreviations (["mipsbe", "mipsle"])
```

##### `Deprecated, non-canonical architecture abbreviation ("x64") converted to canonical abbreviations (["x86_64"])

`x64` is not a supported `Metasploit::Cache::Architecture#abbreviation` because there are multiple 64-bit architectures.
For historical reasons, `x64` is assumed to imply `x86_64`, but there are other 64-bit architectures: `'cbea64'`
(64-bit Cell Broadband Engine Architecture) and `'ppc64'`
(64-bit Performance Optimization With Enhanced RISC - Performance Computing).

To get rid of the warning, change `x86` in the metasploit Module file to `x86_64`.

##### `Has no 'Arch', so assuming 'x86'.

In the early days of metasploit-framework, only `'x86'` architecture was supported, so early Metasploit Modules or those
Metasploit Modules copying those older Metasploit Modules as template may be missing and `'Arch'`, but now with so many
architectures supported, you really should declare `'Arch'` because no when reading the source the reader would need to
understand that no `'Arch'` means just `'`x86'` and **NOT** *all* architectures. You should add `'Arch' => 'x86'` to the
module info Hash.

#### Common Errors from Log

Errors, unlike Warnings prevent a Metasploit Module from being added to the cache.  This can be caused from typos or
omissions in the Metasploit Module that lead to missing metadata required for the Metasploit Module's module type.


##### `Disclosed on can't be blank`

The `'Disclosure Date'` field is missing for an exploit Metasploit Module.  Add `'Disclosure Date'` to the info `Hash`.
If the Metasploit Module does not have a real disclosure date, then use the first commit date for the Metasploit Module.

##### `Referencable references has too few referencable references (minimum is 1 referencable references)`

The `'References'` array cannot be empty.  If no blog post can be found from the original author and no reference
authority, such as CVE, has an identifier, then use `['URL', '<metasploit-framework-blog-post>']` or
`['URL', '<github-url-of-module>']`.

##### `PG::UniqueViolation: ERROR:  duplicate key value violates unique constraint "unique_mc_referencable_references"`

There is a collision in the expanded form of the `References` such as when the
`['<Metasploit::Cache::Authority#abbreviation>', '<Metasploit::Cache::Reference#designation>']` and
`['URL', '<Metasploit::Cache::Reference#url>']` have the same `Metasploit::Cache::Reference#url`

```ruby
'References' =>
        [
          [ 'CVE', '2013-3238' ],
          [ 'PMASA', '2013-2'],
          [ 'waraxe', '2013-SA#103' ],
          [ 'EDB', '25003'],
          [ 'OSVDB', '92793'],
          [ 'URL', 'http://www.waraxe.us/advisory-103.html' ],
          [ 'URL', 'http://www.phpmyadmin.net/home_page/security/PMASA-2013-2.php' ]
        ]
```

Above, `[ 'waraxe', '2013-SA#103' ]` has the same `Metasploit::Cache::Reference#url` as
`[ 'URL', 'http://www.waraxe.us/advisory-103.html' ]` and `[ 'PMASA', '2013-2']` has the same
`Metasploit::Cache::Reference#url` as `[ 'URL', 'http://www.phpmyadmin.net/home_page/security/PMASA-2013-2.php' ]`.

Remove the `['URL', '<Metasploit::Cache::Reference#url>']` format references in favor of the 
`['<Metasploit::Cache::Authority#abbreviation>', '<Metasploit::Cache::Reference#designation>']` references.

##### `No seeded Metasploit::Cache::Authority with abbreviation`

If this is a typo, correct it; otherwise, add new `Metasploit::Cache::Authority` by
[following the instruction for adding a new seed](#seeds).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)
