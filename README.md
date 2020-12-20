# Denv

denv is small configuration utility based on the idea of profiles. It is
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
  - [denv](#denv)
  - [Dep](#dep)
  - [Pkg](#pkg)
  - [Utils](#utils)

## Motivation 

Overtime, packages get deprecated, configuration get changed and new ideas and
workflow emerge and I'd like to easily capture that :D.

## Milestones

- Pkg Module
  - [X] adds, removes, and updates pkg for aur and brew.
  - [ ] accepts a map instead of pkg name for later processing and logic.
  - [ ] supports language-specific package managers e.g. NPM.
  
- Dep Module
  - [X] adds, removes, and updates deps.
  - [ ] build and process build scripts for deps.
  - [ ] support other host than github.

- Profile Module
  - [ ] adds, removes, and updates profiles.
  
- Logging and info Module 
  - [X] basic logging on pkgs/deps/profiles actions.
  - [ ] Log an array sorted by date
  - [ ] Print a table of pkg/dep/profiles installed.
  - [ ] Print a table of pkg/dep not registered in profiles.
  
- Conf Module
  - [ ] Create a module for operation specific to configuration.
  - [ ] Use recently changed denv configuration file as opposed to first non-nil path.
  - [ ] Use config file from URL

## Notes

**denv Configuration**

```clj 
{:repo "tami5/runtime"                 # Where the user dotfiles can be cloned from
 :path "repos/runtime"                 # Where the `dt-repo` will be cloned to and later used.
 :profiles "profiles"                  # Where will profiles definitions be stored.
 :resources "store"                    # Where will configuration files and directories are located.
 :deps "local"                         # Where local deps that needs build are located.
 :notify false                         # Whether to enable system level notifcation.
 :init  {:archlinux "init/setup_arch"  # What file to run during config init. 
         :darwin "init/setup_macos"}}
```


**Profile definition** 


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

**Pkgs definition**

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

**Dep definition**

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
