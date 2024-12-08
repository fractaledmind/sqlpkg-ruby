# sqlpkg-ruby

[sqlpkg](https://sqlpkg.org/) is the (unofficial) SQLite package registry. This gem provides a Ruby interface to [its CLI](https://github.com/nalgeon/sqlpkg-cli).

## Installation

Install the gem and add to the application's Gemfile by executing:
```shell
bundle add sqlpkg
```

If bundler is not being used to manage dependencies, install the gem by executing:
```shell
gem install sqlpkg
```

After installing the gem, run the installer:
```shell
rails generate sqlpkg:install
```

The installer does three things:

1. creates an empty `.sqlpkg/` directory, which ensures that `sqlpkg` will run in "project scope" and not "global scope" (see [the `sqlpkg-cli` README](https://github.com/nalgeon/sqlpkg-cli#project-vs-global-scope) for more information)
2. creates an empty `sqlpkg.lock` file, which `sqlpkg` will use to store information about the installed packages (see [the `sqlpkg-cli` README](https://github.com/nalgeon/sqlpkg-cli#lockfile) for more information)
3. creates an initializer file at `config/initializers/sqlpkg.rb` which will patch the `SQLite3Adapter` to automatically load the extensions installed in the `.sqlpkg/` directory whenever the database is opened

Once properly integrated into your Rails application, you can install any extension listed on [the `sqlpkg` registry](https://sqlpkg.org/all/) by executing:
```shell
bundle exec sqlpkg install PACKAGE_IDENTIFIER
```

When exploring the [the `sqlpkg` registry](https://sqlpkg.org/all/), the `PACKAGE_IDENTIFIER` needed to install an extension is the title found in the cards, always in `owner/name` format.

This gem wraps the standalone executable version of the [sqlpkg-cli](https://github.com/nalgeon/sqlpkg-cli#download-and-install-preferred-method). These executables are platform specific, so there are actually separate underlying gems per platform, but the correct gem will automatically be picked for your platform.

Supported platforms are:

* arm64-darwin (macos-arm64)
* x86_64-darwin (macos-x64)
* arm64-linux (linux-arm64)
* x86_64-linux (linux-x64)

### Using a local installation of `sqlpkg`

If you are not able to use the vendored standalone executables (for example, if you're on an unsupported platform), you can use a local installation of the `sqlpkg` executable by setting an environment variable named `SQLPKG_INSTALL_DIR` to the directory containing the executable.

For example, if you've installed `sqlpkg` so that the executable is found at `/usr/local/bin/sqlpkg`, then you should set your environment variable like so:

``` sh
SQLPKG_INSTALL_DIR=/usr/local/bin
```

This also works with relative paths. If you've installed into your app's directory at `./.bin/sqlpkg`:

``` sh
SQLPKG_INSTALL_DIR=.bin
```

## Usage

```shell
bundle exec sqlpkg help
┌────────────────────────────────────────────────┐
│ sqlpkg is an SQLite package manager.           │
│ Use it to install or update SQLite extensions. │
│                                                │
│ Commands:                                      │
│ help       Display help                        │
│ info       Display package information         │
│ init       Init project scope                  │
│ install    Install packages                    │
│ list       List installed packages             │
│ uninstall  Uninstall package                   │
│ update     Update installed packages           │
│ version    Display version                     │
│ which      Display path to extension file      │
└────────────────────────────────────────────────┘
```

You can get the path to an installed extension using the `Sqlpkg.path_for` method, e.g.:

```ruby
Sqlpkg.path_for("nalgeon/uuid")
# => "./.sqlpkg/nalgeon/uuid/uuid.dylib"
```

You can also use the shorter `.[]` alias:

```ruby
Sqlpkg["nalgeon/uuid"]
# => "./.sqlpkg/nalgeon/uuid/uuid.dylib"
```

If you try to access an extension that hasn't been installed, a `Sqlpkg::ExtensionNotInstalledError` will be raised:

```ruby
Sqlpkg["nalgeon/ulid"]
# raises Sqlpkg::ExtensionNotInstalledError
```

This feature is particulary useful for the [new Rails feature](https://github.com/rails/rails/pull/53827) and [`sqlite3-ruby` feature](https://github.com/sparklemotion/sqlite3-ruby/pull/586) that allows automatically loading extensions via the `extensions` keyword defined in the Rails `config/database.yml` or the `SQLite3::Database.new` method call. You can now use either:

```yaml
development:
  adapter: sqlite3
  extensions:
    - <%= Sqlpkg.path_for("asg017/ulid") %>
```

or if you are using `SQLite3::Database` directly:

```ruby
db = SQLite3::Database.new(":memory:", extensions: [Sqlpkg.path_for("asg017/ulid")])
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. For maintainers, to release a new version, run `bin/release $VERSION`, which will create a git tag for the version, push git commits and tags, and push all of the platform-specific `.gem` files to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fractaledmind/sqlpkg-ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/fractaledmind/sqlpkg-ruby/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Sqlpkg::Ruby project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/fractaledmind/sqlpkg-ruby/blob/main/CODE_OF_CONDUCT.md).
