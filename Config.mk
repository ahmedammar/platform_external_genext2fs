# $(1): src directory
# $(2): output file
# $(3): label (if any)
# $(4): if true, add journal
# $(5): partition size in MB
define build-userimage-ext2-target
	@mkdir -p $(dir $(2))
	$(hide) num_blocks=`du -sk $(1) | tail -n1 | awk '{print $$1;}'`;\
	if [ $$num_blocks -lt 20480 ]; then extra_blocks=3072; \
	else extra_blocks=20480; fi ; \
	if [ "$(5)" != "" ]; then num_blocks=$(5); num_inodes=4096; \
	else num_blocks=`expr $$num_blocks + $$extra_blocks` ; \
	num_inodes=`find $(1) | wc -l` ; num_inodes=`expr $$num_inodes + 500`; fi; \
	$(MKEXT2IMG) -a -d $(1) -b $$num_blocks -N $$num_inodes -m 0 $(2);
	$(if $(strip $(3)),\
		$(hide) $(TUNE2FS) -L $(strip $(3)) $(2))
	$(TUNE2FS) -j $(2)
	$(TUNE2FS) -O extents,uninit_bg,dir_index $(2)
	$(TUNE2FS) -C 1 $(2)
	$(E2FSCK) -fyD $(2) ; [ $$? -lt 4 ]
endef
