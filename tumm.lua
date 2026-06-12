#!/usr/bin/env lua
-- tumm.lua: useful short lua functions, collected from the
-- bits that kept reappearing across my other lua projects.
-- (c) 2026 Tim Menzies <timm@ieee.org>, MIT license
-- usage: local l = require"tumm"
-- demos: lua tumm.lua --all   (or --lists --stats --str ...)
local l = {}
local abs,floor,log = math.abs, math.floor, math.log
local max = math.max

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

-- identity; default fn arg (n.b. stats twin is l.sames)
function l.same(x) return x end

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

-- shallow copy of the list part of t (map + identity)
function l.copy(t) return l.map(t, l.same) end

-- deep copy: recurses, keeps metatables, survives cycles
function l.deepCopy(t,seen,    u)
  if type(t) ~= "table" then return t end
  if seen and seen[t] then return seen[t] end
  seen = seen or {}
  u = {}; seen[t] = u
  for k,v in pairs(t) do
    u[l.deepCopy(k,seen)] = l.deepCopy(v,seen) end
  return setmetatable(u, getmetatable(t)) end

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
  s=0; fn = fn or l.same
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

-- pooled stdev of two raw samples
function l.pooledSd(xs,ys,    nx,sx,ny,sy)
  nx,sx = #xs, (select(2, l.welfords(xs)))
  ny,sy = #ys, (select(2, l.welfords(ys)))
  return (((nx-1)*sx*sx + (ny-1)*sy*sy)/(nx+ny-2))^0.5 end

-- Cliff's delta effect size; ys pre-sorted
function l.cliffsDelta(xs,ys,    n,p,ngt,nlt)
  n,p,ngt,nlt = #xs,#ys,0,0
  for _,v in ipairs(xs) do
    ngt = ngt + l.bisect(ys,v,true)
    nlt = nlt + (p - l.bisect(ys,v)) end
  return abs(ngt-nlt)/(n*p) end

-- Kolmogorov-Smirnov max CDF gap; both pre-sorted
function l.ks(xs,ys,    n,p,d,gap)
  n,p,d = #xs,#ys,0
  gap = function(v)
    return abs(l.bisect(xs,v)/n - l.bisect(ys,v)/p) end
  for _,v in ipairs(xs) do d=max(d,gap(v)) end
  for _,v in ipairs(ys) do d=max(d,gap(v)) end
  return d end

-- xs,ys stats-same? all of: mid gap<=eps, cliffs, ks
function l.sames(xs,ys,eps,cliffs,ksconf,    n,p,a,b)
  eps,cliffs,ksconf = eps or 0, cliffs or 0.195, ksconf or 1.36
  a,b = l.sort({table.unpack(xs)}), l.sort({table.unpack(ys)})
  n,p = #a,#b
  if abs(a[n//2+1]-b[p//2+1])<=eps then return true end
  if l.cliffsDelta(a,b)>cliffs then return false end
  return l.ks(a,b) <= ksconf*((n+p)/(n*p))^0.5 end

-- dict[k]=nums -> all keys stats-same as best mu
function l.topTier(dict,cmp,eps,cliffs,ksconf,
                   out,names,best,cand,th)
  out={}
  names = l.keysort(l.keys(dict),
                    function(k) return (l.welfords(dict[k])) end,
                    cmp)
  best = dict[names[1]]
  out[names[1]] = (l.welfords(best))
  for i=2,#names do
    cand = dict[names[i]]
    th = (eps or 0) * l.pooledSd(best, cand)
    if not l.sames(best,cand,th,cliffs,ksconf) then break end
    out[names[i]] = (l.welfords(cand)) end
  return out end

-- ## Confuse -----------------------------------------------
local Confuse = {}
l.Confuse = Confuse

-- ctor: confusion matrix counts + klass set
function Confuse.new(file)
  return l.new(Confuse, {t={}, klasses={}, file=file or ""}) end

-- bump count for (want,got) pair
function Confuse.add(i,want,got)
  i.t[want]       = i.t[want] or {}
  i.t[want][got]  = (i.t[want][got] or 0) + 1
  i.klasses[want], i.klasses[got] = true, true end

-- per-klass {tn,fn,fp,tp,acc,pred,pf,pd,...}
function Confuse.scores(i,    out,tn,fn,fp,tp,n)
  out = {}
  for _,klass in ipairs(l.sort(l.keys(i.klasses))) do
    tn,fn,fp,tp = 0,0,0,0
    for want,gots in pairs(i.t) do
      for got,cnt in pairs(gots) do
        if     want==klass and got==klass then tp=tp+cnt
        elseif want==klass                then fn=fn+cnt
        elseif got==klass                 then fp=fp+cnt
        else   tn=tn+cnt end end end
    n = tn+fn+fp+tp
    out[1+#out] = {klass=klass, tn=tn, fn=fn, fp=fp, tp=tp,
      n=n, file=i.file,
      acc =100*(tp+tn)/(n+1e-32),
      pred=100*tp/(tp+fp+1e-32),
      pf  =100*fp/(fp+tn+1e-32),
      pd  =100*tp/(tp+fn+1e-32)} end
  return out end

-- print confusion stats as formatted table
function Confuse.show(i,    hdr,row)
  hdr = "%5s %5s %5s %5s %5s %5s %5s %5s %5s %-8s %s"
  row = "%5d %5d %5d %5d %5.0f %5.0f %5.0f %5.0f %5d %-8s %s"
  print(hdr:format("tn","fn","fp","tp","acc","pred","pf","pd",
                   "n","klass","file"))
  for _,r in ipairs(i:scores()) do
    print(row:format(r.tn, r.fn, r.fp, r.tp,
      r.acc, r.pred, r.pf, r.pd, r.n, r.klass, r.file)) end end

-- ## test --------------------------------------------------

-- cases {tag,got,want[,tol]}; print each; ok[,failTag]
function l.chk(...)
  for _,c in ipairs{...} do
    l.o2(c[1], c[2])
    if not (c[4] and abs(c[2]-c[3])<=c[4]
            or c[2]==c[3]) then
      return false, c[1] end end
  return true end

-- run one eg: seed reset + pcall; returns err|nil
function l.run1(fn,    ok,flag,msg)
  l.srand(1)
  ok, flag, msg = pcall(fn)
  if not ok      then return "ERR "..tostring(flag) end
  if flag==false then return tostring(msg) end end

-- argv eg-runner: -h help, --all, or any --name in egs
function l.main(eg,usage,    a,fails,err,names)
  a, fails = _G.arg, {}
  if #a==0 or a[1]=="-h" or a[1]=="--help" then
    print(usage or "usage: --all | ACTION...")
    for _,k in ipairs(l.sort(l.keys(eg))) do
      print("  "..k) end
    return end
  names = a[1]=="--all" and l.sort(l.keys(eg)) or a
  for _,txt in ipairs(names) do
    if eg[txt] then
      print("--",txt)
      err = l.run1(eg[txt])
      if err then l.push(fails, txt..": "..err) end end end
  for _,f in ipairs(fails) do print("FAIL", f) end
  print(#fails==0 and "all pass"
        or (#fails.." failed")) end

-- ## egs (lua tumm.lua --name | --all | -h) ----------------
local eg = {}

eg["--lists"] = function(    t,u)
  t = l.shuffle{3,1,2,5,4}
  u = l.sort(l.list{a=1,b=2,c=3})
  return l.chk({"shuffle",#t,5},
    {"sort",l.sort(l.copy(t))[1],1},
    {"same",l.same(42),42},
    {"list",u[1]..","..u[3],"1,3"},
    {"slice",l.slice({10,20,30,40,50},2,-2)[3],40},
    {"keysort",l.keysort({{1},{0},{2}},l.nth(1))[1][1],0},
    {"argmin",
      l.argmin({30,10,50},function(x) return x end),2}) end

eg["--copy"] = function(    a,b,c)
  c = l.copy{10,20,30}
  a = l.new({}, {x={1,2}, y=3})
  a.self = a                                       -- cycle
  b = l.deepCopy(a)
  return l.chk({"copy",c[2],20},
    {"fresh",b.x ~= a.x,true},
    {"vals",b.x[2],2},
    {"cycle",b.self == b,true},
    {"mt",getmetatable(b) == getmetatable(a),true}) end

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

eg["--sames"] = function(    mk,a,b,c,tier)
  mk = function(off,    u) u={}
    for _=1,50 do u[1+#u]=l.rand()+off end; return u end
  a,b,c = mk(0), mk(0), mk(5)
  tier = l.topTier({a=a,b=b,c=c}, nil, 0.35)
  return l.chk(
    {"cliffs",l.cliffsDelta({1,2,3},{10,11,12}),1},
    {"ks",l.ks({1,2,3},{10,11,12}),1},
    {"pooledSd",
      l.pooledSd({1,2,3,4,5},{1,2,3,4,5}),1.5811,1E-3},
    {"same",l.sames(a,b,0.35*l.pooledSd(a,b)),true},
    {"diff",l.sames(a,c,0.35*l.pooledSd(a,c)),false},
    {"tier a+b",tier.a~=nil and tier.b~=nil,true},
    {"tier no c",tier.c,nil}) end

eg["--confuse"] = function(    cf)
  cf = Confuse.new("data.csv")
  for _=1,50 do cf:add("yes","yes") end
  for _=1, 5 do cf:add("yes","no")  end
  for _=1, 3 do cf:add("no","yes")  end
  for _=1,40 do cf:add("no","no")   end
  cf:show(); return true end

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

if (arg or {})[0] and arg[0]:find"tumm%.lua$" then
  l.main(eg, "usage: lua tumm.lua --all | ACTION...") end
return l
