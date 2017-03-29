# v0.1.2

- support `@:module_path` for external make modules declaration
- idea project excludes modules without idea plugin declaration
- fix task order comparator

# v0.1.0

- `hxlog` for logging. Dependency has been added
- `Sys.command` has been replaced by `CL.command`
- Fix for TestTask nodejs / js targets compilation
- Running changed to `neko make.n` by default. Before it was `-cmd neko make.n`, so `haxe` process was blocking `stdout`
in case of `Process` usage.

# v0.0.1
- Initial concept