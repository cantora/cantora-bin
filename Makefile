
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
	cp -vsn $(CURDIR)/build/* ~/bin/
	cp -vsn $(CURDIR)/sh/* ~/bin/
	cp -vsn $(CURDIR)/rb/* ~/bin/

clean:
	rm -v $(BUILD)/*
