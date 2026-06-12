# vim: ts=2 sw=2 sts=2 et :
# knobs only; generic targets (help doctor check push hist sh vi mux pdf)
# live in $(KONFIG)/Makefile
KONFIG ?= ../konfig

APP     := kah
MAIN    := kah.lua
EXT     := lua
LANG    := lua
COMMENT := --
LINT     = luacheck --ignore 211 212 611 612 631 -- *.lua
TOOLS   := lua:run luacheck:check
PKG     := lua gawk luacheck neovim tmux

# loud failure if konfig not cloned (include resolves at parse time)
$(KONFIG)/Makefile:
	@test -f $@ || { echo "missing konfig: git clone http://tiny.cc/konfig $(KONFIG)"; exit 1; }
include $(KONFIG)/Makefile

## kah-specific ----------------------------------------------

ALL: ## test: every eg ends "all pass"
	@lua kah.lua --all | tee /dev/stderr | grep -q "^all pass"

test: ## run every UPPERCASE rule
	@gawk -F: '/^[A-Z][A-Z_]*:[^=]/ {print $$1}' $(MAKEFILE_LIST) | \
	  sort -u | while read t; do \
	    printf "\n=== %s ===\n" "$$t"; $(MAKE) -s $$t; done
