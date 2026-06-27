<!-- Copyright (c) 2026 Tim Menzies, MIT License https://opensource.org/licenses/MIT -->
<a href="https://timm.fyi"><img align="right" alt="Author" src="https://img.shields.io/badge/Author-timm-dc143c?logo=readme&logoColor=white"></a><img align="right" alt="Language" src="https://img.shields.io/badge/Language-Lua-000080?logo=lua&logoColor=white"><img align="right" alt="License" src="https://img.shields.io/badge/License-MIT-32cd32?logo=open-source-initiative&logoColor=white"><img align="right" alt="Purpose" src="https://img.shields.io/badge/Purpose-Utilities·Teaching-7b68ee?logo=githubcopilot&logoColor=white">

### [http://tiny.cc/kah-lua](http://tiny.cc/kah-lua)
KAH: one file, ~50 short Lua functions that kept reappearing
across my other Lua projects: lists, strings, random, csv, stats
(incl. effect-size tests + confusion matrix), objects, tests. No
dependencies beyond Lua 5.3+. Every function: one line of
comment, a few lines of code, 65 columns max.

```bash
# install and test
git clone http://tiny.cc/konfig ../konfig
git clone http://tiny.cc/kah-lua kah && cd kah
lua kah.lua --all
```

<a href="http://tiny.cc/kah-lua"><img width="150" align="right" alt="qr" src="https://tiny.cc/tiny/qr-image/tiny.cc~kah-lua~l~150.png"></a>

**Sections:** [NAME](#name) | [SYNOPSIS](#synopsis) | [OPTIONS](#options) | [TESTS](#tests) | [OUTPUT](#output) | [EXIT](#exit) | [SEE ALSO](#see-also) | [LICENSE](#license) | [AUTHOR](#author)

**Files:** [kah.lua](http://tiny.cc/kah-lua#file-kah-lua) | [kah-1.0.0-1.rockspec](http://tiny.cc/kah-lua#file-kah-1-0-0-1-rockspec) | [Makefile](http://tiny.cc/kah-lua#file-makefile)

## NAME

    kah - useful short lua functions. one file, zero deps,
    Lua 5.3+. import as a library or run its demos from the
    command line.

## SYNOPSIS

    local l = require"kah"           -- library
    lua kah.lua [-h] [--ACTION]...   -- demos/tests

    luarocks install kah             -- via luarocks

## OPTIONS

    Topic areas inside kah.lua (one ## section each):

      rand     srand rand any anys shuffle pickDict irwinHall
               (portable Park-Miller PRNG: seeded runs match
                across machines and languages)
      lists    push sort same nth lt gt map kap keys list
               copy deepCopy slice keysort argmin
      objects  new (metatable binder; tiny OO in one line)
      strings  fmt trim thing o o2
      files    path csv
      stats    sum mean welford welfords sd mode ent bisect
               pooledSd cliffsDelta ks sames topTier
      Confuse  confusion matrix: new add scores show
      test     chk run1 main (reusable argv eg-runner: any
               eg{} table gets -h/--all/--name dispatch free)

    n.b. same(x) = identity; sames(xs,ys) = stats-same
    (median gap + Cliff's delta + KS, all must agree).

## TESTS

    Every action is a test; --all runs them all:

      lua kah.lua --all
      lua kah.lua --lists --stats      # run a subset

    Actions: --confuse --copy --csv --lists --obj --rand
             --sames --stats --str
    Each prints `tag = value` check lines; runs end
    "all pass" or "N failed".

## OUTPUT

    E.g. `lua kah.lua --stats`:

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
    luamine   http://tiny.cc/luamine  AI primitives built in
                                      this same style
    optimiz   http://tiny.cc/optimiz  example CSV datasets

## LICENSE

    MIT. https://choosealicense.com/licenses/mit/

## AUTHOR

    Tim Menzies <timm@ieee.org>
