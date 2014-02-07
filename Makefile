
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

install: $(BINS)
	mkdir -p ~/bin
	chmod 755 $(CURDIR)/build/*
	chmod 755 $(CURDIR)/sh/*
	chmod 755 $(CURDIR)/rb/*
	cd ~/bin && for f in $(CURDIR)/build/*; do ln -fs $$f; done
	cd ~/bin && for f in $(CURDIR)/sh/*; do ln -fs $$f; done
	cd ~/bin && for f in $(CURDIR)/rb/*; do ln -fs $$f; done

clean:
	rm -v $(BUILD)/*
