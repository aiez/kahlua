package = "tumm"
version = "0.1-1"
source = {
  -- gist git url; tiny.cc/tumm redirects to the gist page
  url = "git+https://gist.github.com/timm/TUMM_GIST_ID.git"
}
description = {
  summary = "Useful short lua functions (lists, csv, stats, rand, tests)",
  detailed = [[
TUMM = Tim's Useful Micro Methods. One file, ~40 short Lua
functions that recur across the author's Lua projects: list ops
(push, map, kap, keysort, slice, argmin), string coercion and
pretty-print (thing, o), csv streaming, incremental stats
(welford, sd, ent, mode, bisect), a portable seeded PRNG, a
one-line metatable OO binder, and a tiny test harness (chk).
Run `lua tumm.lua --all` for the self-test/demo suite.]],
  homepage = "http://tiny.cc/tumm",
  license = "MIT",
  labels = { "utilities", "lists", "csv", "statistics" },
  maintainer = "Tim Menzies <timm@ieee.org>"
}
dependencies = {
  "lua >= 5.3"
}
build = {
  type = "builtin",
  modules = { tumm = "tumm.lua" }
}
