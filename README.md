# Rs::Result

Bring the Rust [Result Option] type to Ruby

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add rs-result

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install rs-result

## Usage

```ruby
require "rs/result"

x = Some.new(2)
x = None.new

x = Ok.new(-3)
x = Err.new("Some error message")
```
## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/initdc/rs-result.
