# hxmake
[![Build Status](https://travis-ci.org/eliasku/hxmake.svg?branch=master)](https://travis-ci.org/eliasku/hxmake)
[![Build status](https://ci.appveyor.com/api/projects/status/lxmpp7d9pfoyd7dq/branch/master?svg=true)](https://ci.appveyor.com/project/eliasku/hxmake/branch/master)

Build tools for Haxe

### First install
1. Install library

`haxelib git hxmake https://github.com/eliasku/hxmake.git`

or clone source code and install as `dev` version

`haxelib dev hxmake path/to/hxmake`

2. Build hxmake and install command-line alias

`haxelib run hxmake _`

Enter system password if required to install alias

### Usage
`hxmake` - run hxmake

`hxmake _` - rebuild hxmake tool and reinstall command-line alias

`hxmake all arguments you need` - usage

`hxmake idea haxe` - run `idea` and `haxe` tasks for project

### Running steps and environment
1. Linked modules are scanned from current-working-directory (Haxe compiler)
2. Build scripts class-path are added at compile-time (Haxe compiler)
3. Compiled make program is running (Haxe interpreter or Neko stand-alone application)

# Status
Is under development

# What is hxmake about
1. Delivering make scripts and building tasks for Haxe projects
2. Haxe language for everything: makes, tasks, plugins, whatever
3. Should run on MacOS / Windows / Linux

### Cache your make program cases
You able to add `--neko` to arguments, in this case hxmake will generate make.n in your current working directory,
and will run it as usual but with `neko`, so after that you able to re-run your make with same arguments:

`neko make.n`

But keep in mind that make.n is generated just for your first hxmake input arguments. For example you could build
`hxmake test --neko`, and rename `make.n` to `make-tests.n` and when you will run it - it will make the same as
`hxmake test`


# TODO:
- Core: re-install on windows, cannot overwrite self executable
