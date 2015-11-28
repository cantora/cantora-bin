
CURDIR_SRCS 	= $(wildcard *.c)
BUILD			= build
MKBUILD			:= $(shell mkdir -p $(BUILD) )
BINS			= $(patsubst %.c, $(BUILD)/%, $(CURDIR_SRCS) )
CXX_FLAGS		= -Wall -Wextra
CXX_CMD			= gcc

default: all

.PHONY: all
all: $(BINS)

$(BUILD)/%: %.c
	$(CXX_CMD) $(CXX_FLAGS) $< -o $@

.PHONY: permissions
permissions: $(BINS)
	find ./build ./sh ./rb ./py ./awk \
	  ! -perm 755 \
	  -exec chmod 755 \{\} \;

.PHONY: install
install: permissions
	mkdir -p ~/bin
	cd ~/bin && for f in $(CURDIR)/build/*; do ln -fs $$f; done
	cd ~/bin && for f in $(CURDIR)/sh/*; do ln -fs $$f; done
	cd ~/bin && for f in $(CURDIR)/rb/*; do ln -fs $$f; done
	cd ~/bin && for f in $(CURDIR)/py/*; do ln -fs $$f; done
	cd ~/bin && for f in $(CURDIR)/awk/*; do ln -fs $$f; done

clean:
	rm -v $(BUILD)/*
