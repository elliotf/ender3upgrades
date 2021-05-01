all: stls

define render_stl_template

stls: stl/$(1)

stl/$(1) : stl/$(1).scad
	openscad-nightly -m make -o $$@.stl $$^ && echo $$^

.PHONY : stl/$(1)

endef

scads := $(foreach scad, $(wildcard stl/*.scad),$(patsubst %.scad,%,$(notdir $(scad))))

$(foreach scad, $(scads), $(eval $(call render_stl_template,$(scad))))
