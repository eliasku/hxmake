# hxmake
Build tools for Haxe

[![Build Status](https://travis-ci.org/eliasku/hxmake.svg?branch=develop)](https://travis-ci.org/eliasku/hxmake)
[![Build Status](https://ci.appveyor.com/api/projects/status/lxmpp7d9pfoyd7dq/branch/develop?svg=true)](https://ci.appveyor.com/project/eliasku/hxmake)

[![Lang](https://img.shields.io/badge/language-haxe-orange.svg)](http://haxe.org)
[![Version](https://img.shields.io/badge/version-v0.2.5-green.svg)](https://github.com/eliasku/hxmake)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](http://opensource.org/licenses/MIT)

### Installation

```
haxelib install hxmake
haxelib run hxmake _
```
_Enter system password if required to install alias_

### Usage

`hxmake` - run hxmake

`hxmake _` - rebuild hxmake tool and reinstall command-line alias

`hxmake all arguments you need` - usage

`hxmake idea haxe` - run `idea` and `haxe` tasks for project

### Examples

- General multi-module project: https://github.com/eliasku/hxmake-example
- `hxmake` library module: https://github.com/eliasku/hxmake/blob/develop/make/HxMake.hx

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

You able to add `--haxe` to arguments, in this case hxmake will be runned in compile-time on `macro` context,
By default file `make.n` will be generated and executed with your current `neko`. This program will include all your built-in arguments,
but you able to run it with additional arguments. You need to recompile your make if you modify your make-scripts or
change your project in multi-module perspective.

Regular make program:

`hxmake` - just build your make program

`neko make.n test --override-test-target=js` - for example, run your make program with additional arguments

Specified make program:

`hxmake test --override-test-target=js` - build make program which will always run `test` task for `js` target

`neko make.n  --override-test-target=flash` - and run your `test` task, but for `js` and `flash` target

### Built-in Tasks

`hxmake _` - Rebuild and install `hxmake` binary

`hxmake modules` - Prints modules in structure of project

`hxmake tasks` - Prints list of available tasks

### Built-in Options

`--verbose`: Enables `debug` and `trace` log levels

`--silent`: Mute logger output

`--make-compiler-log`: Enables compile-time logging from `CompileTime.log`

`--make-compiler-mode`: Run make in haxe compiler-mode `--interp` (EXPEREMENTAL)

`--make-compiler-time`: Show Haxe compiler time statistics, adds `--times -D macro-times`

### Logging

Use `MakeLog` or `project.logger` methods for logging in your tasks.
Use `CompileTime.log` for compilation logging.

### Development

- Install with `haxelib` from git repository
```
haxelib git hxmake https://github.com/eliasku/hxmake.git
```
- or checkout manually and set to local directory using `haxelib dev` command
```
haxelib dev hxmake path/to/hxmake
```
- Then do initial rebuild command 
```
haxelib run hxmake _
```

### Task running details
Task will be ran in current working directory of associated module.

Default Task / Sub-Tasks / Functions running order:

1. Sub-Tasks added with `prepend` method.

2. Functions registered with `doFirst` method.

3. Task's `run` logic.

4. Functions registered with `doLast` method.

5. Sub-Tasks added with `then` method.