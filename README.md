# Dotenv

Dotenv is small configuration utility based on the idea of profiles. It is
written to ease the tasks maintaining mission orientated profiles (i.e. set of
deps and pkgs concerning a set or sets of tasks).  [More on the design](#notes)
It isn't stable yet, but as soon it is I will decouple it from my personal
profiles and configurations. For now, feel free to fork and contribute if you
find it to be an interesting way to manage your envs. A good place to start is
to run tests and look for thing to be done.

- [Motivation](#motivation)
- [Milestone](#milestone)
- [TODOS](#todo)
- [Notes](#notes)
- [API](#api)
  - [Dotenv](#dotenv)
  - [Dep](#dep)
  - [Pkg](#pkg)
  - [Utils](#utils)

## Motivation 

Overtime, packages get deprecated, configuration get changed and new ideas and
workflow emerge and I'd like to easily capture that :D.

## Milestones

- [X] Sketch out the design and stuff to work on.
- [X] Implement pkg module.
- [ ] Implement dep module.
- [ ] Implement conf module.
- [ ] Refactor
- [ ] Implement durable storage for storing profiles.
- [ ] Add support for other pkg managers (pip, node ...)

## TODO

- [X] log changes in (profiles, deps, pkgs) on the machine
- [X] consider using yay instead of pacman since it does what pacman do.
- [ ] Refactor utils to submodules or maybe better macros!!
- [ ] Create an shell alias around pacman and brew that will appends new
  package and remove them from a file under `dotenv/cache`
- [ ] add another field to pkg and dep for executing a function or a array of
  functions.
- [ ] move all variables and files names to internal config file. For example,
  dotenv/vars.janet
- [ ] Manage profiles, pkgs and deps through durable database.

## Notes

Profiles defines pkgs and deps to be installed, in addition to function to be
executed, such as run a shell script or janet function, generate a script to
dotenv/bin to be used as part of the profile ...

```clj
{:term-env 
  {:name "Terminal Environment."
   :desc "Setup my terminal env just the way I like."
   :deps deps
   :pkgs pkgs
   ;; Will a profile deps and pkgs will be defined separately based on 
   ;; profiles?  ;; Or they will act as a namespace used to label deps and pkgs? 
   ;; I think the latter is most suited when I implement a db storage.
   ;; Either ways the above fields might used to give some context.
   :exec [func func func] ;; functions to be executed as part of ensuring the
    ;; profile
  }
}
```

Deps are git repos managed independently of a package manager. 
Deps can have optional build method, configuration (or simply true ),
description for installation process and other meta information

```clj
(def example-dep
  {:source "chriskempson/base16-shell"
   :desc "Base16 colors for shell"
   :added 1605072427
   :conf (or true "path/to/conf") ;; true if the conf is as same as the dep name.
   :build (or func "")
   :profile :term-env
  }
}
```


Pkgs are packages available through pacman, aur, and brew. They are exactly
like deps but managed by additional tools

```clj
(def example-pkgs
  {:name (or "name" "alternative name")
   :desc "description about the pkg and it usage."
   :added 1605072427
   :conf (or true "path/to/conf") ;; true if the conf is as same as the dep name.
   :cmd (or func "")
   :profile :term-env
  }
)
```

## API

### Dotenv (0/2)

Main command interface namespace. called through `dotenv cmd`

- [ ] `dotenv/push f []`

Simple wrapper around `git -c $DOTENV push` that pushes changes made in user
config dir with a timestamp and auto generated summary. In the future, it may
incorporate pushing changes made in deps owned by the user. 

- [ ] `dotenv/pull f []`

Simple wrapper around `git -c $DOTENV pull` that pull changes made in the
remote repo. In the future, it may incorporate pulling changes made in deps
owned by the user. 

### Profile (0/2)

- [ ] `profile/ensure f [profile]` 

Takes a profile name as an argument and call a set of functions to ensure that
the profile's deps, pkgs, and scripts are executed.


- [ ] `profile/clean f [&opt profile]`

Takes an optional profile name and deletes symbolic links, pkgs, and deps
related to it. If no argument provided, it will delete everything, leaving no
trace :D.

### Deps (1/5)

- [ ] `dep/root`

Defines where deps will be cloned to.

- [ ] `dep/ensure f [Dep ...]` 

Checks if a dep exists (i.e. the dep is cloned to `dep/dpath`) and is setup
properly. Otherwise, calls `dep/add`. If `force` it will shall call
`dep/remove` then `dep/add`.

- [ ] `dep/add f [dep]` 

Executes a number of function based on the dep fields. Returns `true` if all
operations are successful, otherwise logs errors.

- [ ] `dep/clone f [link fpath &branch]` 

clones `link` to a given `fpath` with `&branch` if provided. It shell call
`dotenv/notify` with the result of running the command.

- [ ] `dep/pull f [fpath]` 

Wrapper around `git -C fpath pull`.

- [ ] `dep/remove f [dep]` 

### Pkgs
- [X] `pkg/ensure f [pkg &opt force]` 

Checks if a pkg exists and is setup properly return. Otherwise, calls
`dep/add`. If `force` it will shall call `d/remove` then `dep/add`.

- [X] `pkg/add f [pkg &opt silent]` 

Given a pkg, install it with brew or pacman based on the os type, and if &force
call `pkg/remove` remove it then reinstall then `pkg/add` 

- [X] `pkg/remove f [pkg &opt silent]` 

Given a pkg, remove it with brew or pacman based on the os type.

- [X] `pkg/upgeade f [pkg &opt silent]` 

Given a pkg, update it with brew or pacman based on the os type.

- [X] `pkg/log f [pkg &opt action]` 

Given a pkg and action, log the newly added, removed and updated packages. As
well as append a log msg with the action and pkg name to `dotenv/cache`
(state.log).

### Conf (0/3)

Set of functions to deal with file system and linking files.

- [ ] `conf/root`

The path where config directories and files is stored, default `./conf`. 

- [ ] `conf/link f [Pkg/Dep]`

Given a pkg or dep and if `:conf` is non-nil, look for configuration under
`conf/root` with same name of the pkg or dep then link it to `XDG_CONFIG_HOME`
and return true. Otherwise, return false.  Additionally,  If a `:conf` is a
string link to the string instead.

- [ ] `conf/remove f [Pkg/Dep]`

Same as link but removes the link.

### Utils

General function that are used across the above namespace.

- [X] `utils/notify f [:title :subtitle :timeout]`

Takes a message and uses either `notify-send` or `alerter`.

- [X] `utils/ep f [path]`

Given a path of a file or a dir, ensure the file or dir exists and return back
the path

- [X] `utils/log f [aspect action l]` 

Given an aspect, action and l (name or msg), append activity to dotenv log
file.
