# Dotenv

Dotenv is small configuration utility written to ease the tasks maintaining
mission orientated profiles (i.e.  set of deps and pkgs concerning a set or
sets of tasks) also as an excuse to experiment with [janet](https://janet-lang.org/) :D.

It isn't stable yet, but as soon it is I will decouple it from my personal
profiles and configurations.  For now, feel free to fork and contribute if you
find it to be an interesting way to manage your envs.


- [Motivation](#motivation)
- [Notes](#notes)
- [API](#api)
  - [Dotenv](#dotenv)
  - [Dep](#dep)
  - [Pkg](#pkg)
  - [Utils](#utils)

## Motivation 

Overtime, packages get deprecated, configuration get changed and new ideas and
workflow emerge and I'd like to easily capture that :D.

## Notes

Profiles defines pkgs and deps to be installed.

```clj
{:term-env 
  {:name "Terminal Environment."
   :desc "Setup my terminal env just the way I like."
   :deps (slurp "./deps.janet") 
   :pkgs (slurp "./pkgs.janet") 
   ;; Will a profile deps and pkgs will be defined separately based on 
   ;; profiles?  ;; Or they will act as a namespace used to label deps and pkgs? 
   ;; I think the latter is most suited when I implement a db storage.
   ;; Either ways the above fields might used to give some context.
   ;;
  }
}
```

- [ ] log changes in (profiles, deps, pkgs) on the machine.
- [ ] Manage profiles, pkgs and deps through durable database.
- [ ] Create an alias around pacman and brew that will simply appends new
  package and remove them from a file under `dotenv/cache`
- [ ] add another field to pkg and dep for executing a function or a array of
  functions.

## API

### Dotenv (0/4)

Main command interface namespace. called through `dotenv cmd`

#### `dotenv/ensure f [Profile]` 

Takes a profile name as an argument and call a set of functions to ensure that
the profile's deps, pkgs, and scripts are executed.

#### `dotenv/push f []`

Simple wrapper around `git -c $DOTENV push` that pushes changes made in current repo with
a timestamp  and auto generated summary. In the future, it may incorporate

pushing changes made in deps owned by `$USER`. 

#### `dotenv/pull f []`

Simple wrapper around `git -c $DOTENV pull` that pull changes made in the
remote repo. In the future, it may incorporate
pulling changes made in deps owned by `$USER`. 

#### `dotenv/clean f [&Profile]`

Takes an optional profile name and deletes symbolic links, pkgs, and deps
related to it. If no argument provided, it will delete everything, leaving no
trace :D.

### Deps (1/5)

Deps are git repos, that are managed independently of a package manager. 
Deps can have optional build method, configuration (or simply true ),
description for installation process and other meta information

```clj
(def example-dep
  {:source "chriskempson/base16-shell"
   :desc "Base16 colors for shell"
   :added 1605072427
   :conf (or true "path/to/conf") ;; true if the conf is as same as the dep name.
   :cmd (or func "")
   :profile :term-env
  }
}
```

#### `dep/root`

Defines where deps will be cloned to.

#### `dep/ensure f [Dep ...]` 

Checks if a dep exists (i.e. the dep is cloned to `dep/dpath`) and is setup
properly. Otherwise, calls `dep/add`. If `force` it will shall call
`dep/remove` then `dep/add`.

#### `dep/add f [dep]` 

Executes a number of function based on the dep fields. Returns `true` if all
operations are successful, otherwise logs errors.

#### `dep/clone f [link fpath &branch]` 

clones `link` to a given `fpath` with `&branch` if provided. It shell call
`dotenv/notify` with the result of running the command.

#### `dep/pull f [fpath]` 

Wrapper around `git -C fpath pull`.

#### `dep/remove f [dep]` 

### Pkgs (4/5)

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
}

```

#### `pkg/ensure f [pkg &opt force]`

Checks if a pkg exists and is setup properly return. Otherwise, calls `dep/add`. If
`force` it will shall call `dep/remove` then `dep/add`.

#### `pkg/add f [pkg &opt silent]`

Given a pkg, install it with brew or pacman based on the os type, and if &force
call `pkg/remove` remove it then reinstall then `pkg/add` 

#### `pkg/remove f [pkg &opt silent]`

Given a pkg, remove it with brew or pacman based on the os type.

#### `pkg/upgeade f [pkg &opt silent]`

Given a pkg, update it with brew or pacman based on the os type.

#### `pkg/log f [pkg &opt action]`

Given a pkg and action, log the newly added packages to
`$XDG_CACHE_HOME/dotenv/added-pkgs`, and removed packages
`$XDG_CACHE_HOME/dotenv/removed-pkgs`, and append log of the package and the
action to `$XDG_CACHE_HOME/dotenv/state.log`.

### Conf (0/3)

Set of functions to deal with file system and linking files.

#### `conf/root`

The path where config directories and files is stored, default `./conf`. 

#### `conf/link f [Pkg/Dep]`

Given a pkg or dep and if `:conf` is non-nil, look for configuration under
`conf/root` with same name of the pkg or dep then link it to `XDG_CONFIG_HOME`
and return true. Otherwise, return false.  Additionally,  If a `:conf` is a
string link to the string instead.

#### `conf/remove f [Pkg/Dep]`

Same as link but removes the link.

### Utils

General function that are used across the above namespace.

#### `dotenv/notify f [:title :subtitle :timeout]`
Takes a message and uses either `notify-send` or `alerter`.

