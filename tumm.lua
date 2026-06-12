#!/usr/bin/env lua
-- tumm.lua: useful short lua functions, collected from the
-- bits that kept reappearing across my other lua projects.
-- (c) 2026 Tim Menzies <timm@ieee.org>, MIT license
-- usage: local l = require"tumm"
-- demos: lua tumm.lua --all   (or --lists --stats --str ...)
local l = {}
local abs,floor,log = math.abs, math.floor, math.log

-- ## rand --------------------------------------------------

-- portable Park-Miller PRNG; seeded runs match anywhere
local Seed = 1
-- set the random seed (any integer)
function l.srand(n)
  Seed = (n or 1) % 2147483647
  if Seed == 0 then Seed = 1 end end

-- rand() -> float in [0,1); rand(n) -> integer in 1..n
function l.rand(n,    r)
  Seed = (16807 * Seed) % 2147483647
  r = Seed / 2147483647
  return n and floor(r * n) + 1 or r end

-- one random item of list t
function l.any(t) return t[l.rand(#t)] end

-- n random items of t (with replacement)
function l.anys(t,n,    u)
  u={}; for _=1,n do u[1+#u]=l.any(t) end; return u end

-- Fisher-Yates shuffle, in place; return t
function l.shuffle(t,    j)
  for i=#t,2,-1 do j=l.rand(i); t[i],t[j]=t[j],t[i] end
  return t end

-- weighted random key from dict (sorted keys: determinism)
function l.pickDict(dct,    ks,s,r)
  ks = l.sort(l.keys(dct))
  s = 0; for _,k in ipairs(ks) do s = s + dct[k] end
  r = s * l.rand()
  for _,k in ipairs(ks) do
    r = r - dct[k]; if r <= 0 then return k end end end

-- Irwin-Hall(3): approx normal sample, mean 0, sd 1
function l.irwinHall()
  return 2*(l.rand()+l.rand()+l.rand()-1.5) end

-- ## lists -------------------------------------------------

-- append x to t; return x
function l.push(t,x) t[1+#t]=x; return x end

-- sort t in place; return t
function l.sort(t,fn) table.sort(t,fn); return t end

-- closure: nth field of a row
function l.nth(n) return function(t) return t[n] end end

-- closure: less-than on field n
function l.lt(n) return function(a,b) return a[n]<b[n] end end

-- closure: greater-than on field n
function l.gt(n) return function(a,b) return a[n]>b[n] end end

-- apply fn to each item -> new list
function l.map(t,fn,    u)
  u={}; for _,v in ipairs(t) do u[1+#u]=fn(v) end; return u end

-- apply fn(k,v) over dict -> new list
function l.kap(t,fn,    u)
  u={}; for k,v in pairs(t) do u[1+#u]=fn(k,v) end
  return u end

-- dict keys -> new list
function l.keys(t)
  return l.kap(t, function(k,_) return k end) end

-- dict values -> new list
function l.list(t,    u)
  u={}; for _,v in pairs(t) do u[1+#u]=v end; return u end

-- shallow copy of the list part of t
function l.copy(t,    u)
  u={}; for i,v in ipairs(t) do u[i]=v end; return u end

-- t[lo..hi] inclusive; negatives count from the end
function l.slice(t,lo,hi,    u,n)
  n  = #t
  lo = lo or 1; if lo < 0 then lo = n + 1 + lo end
  hi = hi or n; if hi < 0 then hi = n + 1 + hi end
  if hi > n then hi = n end
  u={}; for i=lo,hi do u[1+#u]=t[i] end
  return u end

-- sort by fn-derived key (decorate-sort-undecorate)
function l.keysort(t,fn,cmp,    d)
  d = function(x) return {fn(x),x} end
  return l.map(l.sort(l.map(t,d),(cmp or l.lt)(1)),
               l.nth(2)) end

-- index of min-by-fn item (cmp=l.gt for max)
function l.argmin(t,fn,cmp,    best,bv,v)
  cmp = cmp or function(a,b) return a < b end
  best, bv = 1, fn(t[1])
  for i=2,#t do
    v = fn(t[i]); if cmp(v,bv) then best,bv=i,v end end
  return best end

-- ## objects -----------------------------------------------

-- bind metatable mt to t (mt.__index=mt); return t
function l.new(mt,t)
  mt.__index=mt; return setmetatable(t,mt) end

-- ## strings -----------------------------------------------

-- string.format, shortened
l.fmt = string.format

-- strip leading/trailing whitespace
function l.trim(s) return s:match"^%s*(.-)%s*$" end

-- coerce str -> bool | num | str
function l.thing(s)
  return s=="true" or (s~="false" and (tonumber(s) or s)) end

-- pretty-print any value -> str (sorted dict keys)
function l.o(x,    u,kv)
  if type(x)=="number" then
    return floor(x)==x and floor(x)
           or ("%.2f"):format(x) end
  if type(x)~="table" then return tostring(x) end
  kv = function(k,v) return k.."="..l.o(v) end
  u = #x>0 and l.map(x,l.o) or l.sort(l.kap(x,kv))
  return "{"..table.concat(u,", ").."}" end

-- print "tag = o(x)"; return x
function l.o2(s,x) print(s.." =", l.o(x)); return x end

-- ## files -------------------------------------------------

-- expand leading $MOOT (env or ~/gits/moot) and ~
function l.path(s,    home)
  home = os.getenv"HOME" or "~"
  s = s:gsub("^%$MOOT",
             os.getenv"MOOT" or home.."/gits/moot")
  return (s:gsub("^~",home)) end

-- iter csv rows; cells coerced via thing
function l.csv(filename,    f)
  filename = l.path(filename)
  f = io.open(filename)
  assert(f, "cannot open: "..filename)
  return function(    s,u)
    s = f:read()
    if s then
      u={}; for x in s:gmatch"[^,]+" do
              u[1+#u] = l.thing(l.trim(x)) end
      return u
    else f:close() end end end

-- ## stats -------------------------------------------------

-- sum of a list (fn optional: sum of fn(x))
function l.sum(t,fn,    s)
  s=0; fn = fn or function(x) return x end
  for _,v in ipairs(t) do s = s + fn(v) end
  return s end

-- mean of a list
function l.mean(t) return l.sum(t)/#t end

-- online update of n,mu,m2 for one value v (Welford)
function l.welford(v,n,mu,m2,    d)
  n=n+1; d=v-mu; mu=mu+d/n; return n,mu, m2+d*(v-mu) end

-- stdev from welford state n,m2
function l.sd(n,m2) return n<2 and 0 or (m2/(n-1))^0.5 end

-- batch mu,sd of a list, via welford
function l.welfords(xs,    n,mu,m2)
  n,mu,m2=0,0,0
  for _,v in ipairs(xs) do n,mu,m2=l.welford(v,n,mu,m2) end
  return mu, l.sd(n,m2) end

-- highest-count key of dict (sorted scan: stable ties)
function l.mode(t,    out,n)
  n = -1
  for _,k in ipairs(l.sort(l.keys(t))) do
    if t[k] > n then out,n = k,t[k] end end
  return out end

-- shannon entropy (bits) of dict counts
function l.ent(t,    e,n)
  e,n=0,0
  for _,v in pairs(t) do n=n+v end
  for _,v in pairs(t) do e=e - v/n * log(v/n,2) end
  return e end

-- count of t[i]<=x (or <x if strict) in sorted t
function l.bisect(t,x,strict,    lo,hi,mid,go)
  lo,hi = 1,#t
  while lo<=hi do mid=(lo+hi)//2
    go = strict and t[mid]<x
         or (not strict) and t[mid]<=x
    if go then lo=mid+1 else hi=mid-1 end end
  return lo-1 end

-- ## test --------------------------------------------------

-- cases {tag,got,want[,tol]}; print each; ok[,failTag]
function l.chk(...)
  for _,c in ipairs{...} do
    l.o2(c[1], c[2])
    if not (c[4] and abs(c[2]-c[3])<=c[4]
            or c[2]==c[3]) then
      return false, c[1] end end
  return true end

-- ## egs (lua tumm.lua --name | --all | -h) ----------------
local eg = {}

eg["--lists"] = function(    t,u)
  t = l.shuffle{3,1,2,5,4}
  u = l.sort(l.list{a=1,b=2,c=3})
  return l.chk({"shuffle",#t,5},
    {"sort",l.sort(l.copy(t))[1],1},
    {"list",u[1]..","..u[3],"1,3"},
    {"slice",l.slice({10,20,30,40,50},2,-2)[3],40},
    {"keysort",l.keysort({{1},{0},{2}},l.nth(1))[1][1],0},
    {"argmin",
      l.argmin({30,10,50},function(x) return x end),2}) end

eg["--rand"] = function(    d,c,k,n,mu,m2)
  d,c = {a=1,b=10,c=100}, {a=0,b=0,c=0}
  for _=1,1000 do k=l.pickDict(d); c[k]=c[k]+1 end
  n,mu,m2 = 0,0,0
  for _=1,2000 do
    n,mu,m2 = l.welford(l.irwinHall(),n,mu,m2) end
  return l.chk({"pickDict",c.c>c.b and c.b>c.a,true},
               {"irwin mu~0",mu,0,0.1},
               {"irwin sd~1",l.sd(n,m2),1,0.1}) end

eg["--stats"] = function(    n,mu,m2)
  n,mu,m2 = 0,0,0
  for _,v in ipairs{1,2,3,4,5} do
    n,mu,m2 = l.welford(v,n,mu,m2) end
  return l.chk({"mu",mu,3},
    {"sd",l.sd(n,m2),1.5811,1E-3},
    {"sum",l.sum{1,2,3},6}, {"mean",l.mean{1,2,3},2},
    {"mode",l.mode{a=1,b=5,c=2},"b"},
    {"ent",l.ent{a=1,b=1,c=1,d=1},2,1E-9},
    {"bisect",l.bisect({1,2,2,3,5,8},2),3}) end

eg["--str"] = function()
  return l.chk(
    {"int",l.thing"42",42},   {"bool",l.thing"true",true},
    {"str",l.thing"hi","hi"}, {"float",l.o(1.5),"1.50"},
    {"trim",l.trim"  hi ","hi"},
    {"dict",l.o{a=1,b=2},"{a=1, b=2}"},
    {"list",l.o{1,2,3},"{1, 2, 3}"}) end

eg["--csv"] = function(    tmp,f,rows)
  tmp = os.tmpname()
  f = io.open(tmp,"w"); f:write("a,b,c\n1,2,3\n"); f:close()
  rows = {}
  for r in l.csv(tmp) do rows[1+#rows]=r end
  os.remove(tmp)
  return l.chk({"#rows",#rows,2},
    {"head",rows[1][1],"a"}, {"cell",rows[2][3],3}) end

eg["--obj"] = function(    Dog,d)
  Dog = {}
  function Dog.new(s) return l.new(Dog,{name=s}) end
  function Dog.speak(i) return i.name.." woofs" end
  d = Dog.new"rex"
  return l.chk({"new",d:speak(),"rex woofs"}) end

-- run one eg: seed reset + pcall; returns err|nil
local function run1(fn,    ok,flag,msg)
  l.srand(1)
  ok, flag, msg = pcall(fn)
  if not ok      then return "ERR "..tostring(flag) end
  if flag==false then return tostring(msg) end end

-- argv dispatch: -h help, --all, or any --name in egs
local function main(    a,fails,err,names)
  a, fails = _G.arg, {}
  if #a==0 or a[1]=="-h" or a[1]=="--help" then
    print("usage: lua tumm.lua --all | ACTION...")
    for _,k in ipairs(l.sort(l.keys(eg))) do
      print("  "..k) end
    return end
  names = a[1]=="--all" and l.sort(l.keys(eg)) or a
  for _,txt in ipairs(names) do
    if eg[txt] then
      print("--",txt)
      err = run1(eg[txt])
      if err then l.push(fails, txt..": "..err) end end end
  for _,f in ipairs(fails) do print("FAIL", f) end
  print(#fails==0 and "all pass"
        or (#fails.." failed")) end

if (arg or {})[0] and arg[0]:find"tumm%.lua$" then main() end
return l
