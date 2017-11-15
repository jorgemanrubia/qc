# Qc

[![Build Status](https://travis-ci.org/jorgemanrubia/qc.svg?branch=master)](https://travis-ci.org/jorgemanrubia/qc)

Qc is a commandline tool that lets you sync and run your [QuantConnect](https://www.quantconnect.com) backtests.

## Installation

Qc is distributed as a ruby gem. You can install it with:

```
gem install qc
```

## Workflow

1. Run `qc login` for introducing your QuantConnect credentials
2. Run `qc init` on the directory that contains your QuantConnect algorithm
3. Execute `qc` to sync and backtest your algorithm in QuantConnect

## Usage

### Default (no command provided)

```shell
qc
qc --open # To open the results in QuantConnect
```

When no command is provided, it will execute `push`, `compile` and `backtest` in sequence.

### Single commands 

```shell
qc [command]
```

The supported commands are:

| Command| description|
| -- | -- |
| `qc login`| It will ask for the api credentials you can find in [your QuantConnect account page](https://www.quantconnect.com/account). They will be stored in `~/.qc`. You only need to login once. |  
| `qc logout`| Logout from QuantConnect clearing the credentials stored locally.  |
| `qc init`| Initialize the directory of the algo project you are working on. It will ask for a QuantConnect project to link your algo with. You need to run this once for every project you want to sync with QuantConnect. |
| `qc push` | Send your local files to QuantConnect. It will only send the files that changed since the last time you run the command |
| `qc compile` | Compile your project in QuantConnect |
| `qc backtest` | Run the backtest of your algorithm in QuantConnect |
| `qc backtest` | Open the latest results in QuantConnect (only MacOS)|

### Opening the results in QuantConnect (only MacOS)

If you pass `--open` after running a backtest it will open the results in QuantConnect while the backtest is running:

```shell
qc --open
qc backtest --open
```

This option only works on MacOS. quantconnect.com currently doesn't offer an URL endpoint to open backtest results. In MacOS, it will use an Automator workflow that will open the project and show its latest results by simulating a click on the corresponding option. See [this discussion](https://groups.google.com/forum/?utm_medium=email&utm_source=footer#!msg/lean-engine/7AiEl3RVv38/PGnFQzBXAQAJ). 

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
