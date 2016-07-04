# hxmake
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
