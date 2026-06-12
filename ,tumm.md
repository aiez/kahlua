<!-- Copyright (c) 2026 Tim Menzies, MIT License https://opensource.org/licenses/MIT -->
<a href="https://timm.fyi"><img align="right" alt="Author" src="https://img.shields.io/badge/Author-timm-dc143c?logo=readme&logoColor=white"></a><img align="right" alt="Language" src="https://img.shields.io/badge/Language-Lua-000080?logo=lua&logoColor=white"><img align="right" alt="License" src="https://img.shields.io/badge/License-MIT-32cd32?logo=open-source-initiative&logoColor=white"><img align="right" alt="Purpose" src="https://img.shields.io/badge/Purpose-Utilities·Teaching-7b68ee?logo=githubcopilot&logoColor=white">

### [http://tiny.cc/tumm](http://tiny.cc/tumm)
TUMM = Tim's Useful Micro Methods. One file, ~40 short Lua
functions that kept reappearing across my other Lua projects:
lists, strings, random, csv, stats, objects, tests. No
dependencies beyond Lua 5.3+. Every function: one line of
comment, a few lines of code, 65 columns max.

```bash
# install and test
git clone http://tiny.cc/konfig ../konfig
git clone http://tiny.cc/tumm tumm && cd tumm
lua tumm.lua --all
```

<a href="http://tiny.cc/tumm"><img width="150" align="right" alt="qr" src="https://tiny.cc/tiny/qr-image/tiny.cc~tumm~l~150.png"></a>

**Sections:** [NAME](#name) | [SYNOPSIS](#synopsis) | [OPTIONS](#options) | [TESTS](#tests) | [OUTPUT](#output) | [EXIT](#exit) | [SEE ALSO](#see-also) | [LICENSE](#license) | [AUTHOR](#author)

**Files:** [tumm.lua](#file-tumm-lua) | [tumm-0.1-1.rockspec](#file-tumm-0-1-1-rockspec) | [Makefile](#file-makefile)

## NAME

    tumm - useful short lua functions. one file, zero deps,
    Lua 5.3+. import as a library or run its demos from the
    command line.

## SYNOPSIS

    local l = require"tumm"          -- library
    lua tumm.lua [-h] [--ACTION]...  -- demos/tests

    luarocks install tumm            -- via luarocks

## OPTIONS

    Topic areas inside tumm.lua (one ## section each):

      rand     srand rand any anys shuffle pickDict irwinHall
               (portable Park-Miller PRNG: seeded runs match
                across machines and languages)
      lists    push sort nth lt gt map kap keys list copy
               slice keysort argmin
      objects  new (metatable binder; tiny OO in one line)
      strings  fmt trim thing o o2
      files    path csv
      stats    sum mean welford welfords sd mode ent bisect
      test     chk

## TESTS

    Every action is a test; --all runs them all:

      lua tumm.lua --all
      lua tumm.lua --lists --stats     # run a subset

    Actions: --csv --lists --obj --rand --stats --str
    Each prints `tag = value` check lines; runs end
    "all pass" or "N failed".

## OUTPUT

    E.g. `lua tumm.lua --stats`:

      -- --stats
      mu = 3
      sd = 1.58
      ...
      all pass

## EXIT

    0 always (failures print as FAIL lines; grep FAIL to
    detect). Non-zero only on Lua errors.

## SEE ALSO

    konfig    http://tiny.cc/konfig   shared Makefile, dotfiles
    lull      http://tiny.cc/lull     AI primitives built in
                                      this same style
    optimiz   http://tiny.cc/optimiz  example CSV datasets

## LICENSE

    MIT. https://choosealicense.com/licenses/mit/

## AUTHOR

    Tim Menzies <timm@ieee.org>
