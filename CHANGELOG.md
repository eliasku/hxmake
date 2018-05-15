# v0.2.3

- Added hxmake.utils.GitTools#getCurrentTagVersion for retrieving current version from git tag
- Fix `--override-test-target` property for TestTask

# v0.2.2

- Fix #33. Launching of Intellij IDEA project.
- Fix #35. PhantomJS runner for TestTask (neko-tools is still running)
- Fix #36. TestTask servePort parameter (phantomJS runner)

# v0.2.1

- Module `configure` phase
- Added hxmake.utils.Haxelib#remove for removing haxe libraries
- Added null-check for TestTask#testLibrary
- Fix #30. USERPROFILE for Windows 10

# v0.2.0

- Removed deprecated methods
- Order for Task `then`/`prepend`/`doFirst`/`doLast` methods
- Fix task queue builder recursive dependency search
- `Task.func` utility for creation of simple task with closure
- Fix `runBefore`/`runAfter` order with dependency modules
- `finalizedBy` implementation 

# v0.1.8

- Resolve tasks according to module dependencies
- Drop Haxe 3.2.X support, switch CI to Haxe 3.4.X
- Installer code moved to built-in task and will be run in make context
- Built-in Module allows to run default tasks without modules context

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
