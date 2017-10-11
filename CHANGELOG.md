# v0.1.7

- `task.project` alias
- `Task.empty(name, desc)` creates empty task
- Prints property-map on start
- Flash Player trust location PER USER for macOS and Windows
- `--macrolog` enabled traces from compile-time
- Fixed recursive call in `trace(..)` calls
- Add `macros`, `flags`, `flagArguments`, `dce` into `hxmake.test.TestTask` to allow more accurate configuration of compile task
- Fixed phantomjs exit on utest
- Add force `exit` define for swf target for utest
- Utility `ServeTask` starts local server with `nekotools`
- Built-in `ListTasks` prints list of available tasks (`hxmake tasks`)
- Built-in `ListModules` task prints current project modules hierarchy (`hxmake modules`)

# v0.1.6

- Task graph resolving improvements
- Fix Haxe Library redundant update if version is specified
- Obsolete `hxlog.Log` removed (use `MakeLog` instead)
- `module.project.property("--key")` method to get `VALUE` from argument `--key=VALUE`
- `readLines` method in `ProcessResult` object
- `project.findModuleByName` method

# v0.1.5

- `--silent` and `--verbose` options
- TestTask (utest) class-path include module test src by default
- `hxlog` dependency has been removed
- Idea project: generate misc.xml, select Haxe SDK and `out` folder for project

# v0.1.4

- additional support for `haxelib` git and hg libraries sources
- multiple sources and defines for TestTask (`utest`)

# v0.1.3

- support `@:module_path` for external make modules declaration
- idea project excludes modules without idea plugin declaration
- fix task order comparator
- fix haxelib install dev name resolving

# v0.1.0

- `hxlog` for logging. Dependency has been added
- `Sys.command` has been replaced by `CL.command`
- Fix for TestTask nodejs / js targets compilation
- Running changed to `neko make.n` by default. Before it was `-cmd neko make.n`, so `haxe` process was blocking `stdout`
in case of `Process` usage.

# v0.0.1
- Initial concept
