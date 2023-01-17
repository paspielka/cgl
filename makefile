CC      := gcc
STD     := -std=c99
OPTS    := -O1
LIBS    := -lglfw
COMMON  :=
CFLAGS  := -Wall -Wextra -pedantic
LDFLAGS := -framework Cocoa -framework OpenGL -framework IOKit

# - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - -

override project_include_dirs := include
override project_src_dir      := src
override project_build_dir    := build
override project_lib_dirs     := lib
override project_finale       := main
override project_srcs := main.c
# - - - - - - - - - - - - - - - - - - - -

override unify_paths         = $(strip $(sort $(abspath $(strip $(1)))))
override unify_rel_paths     = $(patsubst $(strip $(abspath ./))/%,%,$(call unify_paths,$(1)))
override unify_paths_by      = $(patsubst $(call unify_paths,$(2))/%,%,$(call unify_paths,$(1)))
override build_obj_to_src    = $(addprefix $(addsuffix /,$(project_src_dir)),$(call unify_paths_by,$(patsubst %.o,%,$(1)),$(project_build_dir)))
override build_obj_to_outdir = $(call unify_rel_paths,$(dir $(1)))

override srcs_all      := $(call unify_rel_paths,$(addprefix $(addsuffix /,$(project_src_dir)),$(strip $(project_srcs))))
override srcs_all_dirs := $(call unify_rel_paths,$(dir $(srcs_all)))

override project_common  := $(COMMON)
override project_cflags  := $(strip $(CFLAGS) $(STD) $(OPTS) $(patsubst %,-I%,$(strip $(sort $(project_include_dirs)))))
override project_ldflags := $(strip $(LDFLAGS) $(LIBS) $(patsubst %,-L%,$(strip $(sort $(project_lib_dirs)))))

override build_objs          := $(call unify_rel_paths,$(patsubst $(project_src_dir)/%,$(project_build_dir)/%,$(patsubst %,%.o,$(srcs_all))))
override build_outdirs       := $(call unify_rel_paths,$(project_build_dir) $(dir $(build_objs)))
override build_finale_target := $(project_build_dir)/$(project_finale)

# - - - - - - - - - - - - - - - - - - - -

.PHONY: all
all: $(build_finale_target)

$(build_finale_target): $(build_objs)
	@printf ' ▶ '
	$(CC) $(strip $(project_common)) $(strip $(project_cflags)) -o $@ $^ $(strip $(project_ldflags))
	@echo ''

.SECONDEXPANSION:
$(filter %.c.o,$(build_objs)): $$(call build_obj_to_src,$$@) | $$(call build_obj_to_outdir,$$@)
	@printf ' ▶ '
	$(CC) $(strip $(project_common)) $(strip $(project_cflags)) -o $@ -c $<
	@echo ''

# - - - - - - - - - - - - - - - - - -

$(build_outdirs):
	@mkdir -p $@

# - - - - - - - - - - - - - - - - - -

.PHONY: clean
clean:
	@printf ' ▶ '
	rm -rf $(addprefix ./$(project_build_dir)/, $(project_finale) *.o *.elf *.img *.out */)
	@echo ''
