# v0.0.3

- `hxlog` for logging. Dependency has been added
- `Sys.command` has been replaced by `CL.command`

### StdOut
Running changed to `neko make.n` by default. Before it was `-cmd neko make.n`, so `haxe` process was blocking `stdout`
in case of `Process` usage.

# v0.0.1
- Initial concept