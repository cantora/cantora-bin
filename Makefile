
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

clean:
	rm -v $(BUILD)/*
