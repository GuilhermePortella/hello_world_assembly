AS := clang
BUILD_DIR := build

PROGRAMS := hello loop calling_convention

.PHONY: all clean run-hello run-loop run-calling-convention

all: $(PROGRAMS:%=$(BUILD_DIR)/%)

$(BUILD_DIR):
	mkdir -p $@

$(BUILD_DIR)/%: %.s | $(BUILD_DIR)
	$(AS) -arch arm64 $< -o $@

run-hello: $(BUILD_DIR)/hello
	./$(BUILD_DIR)/hello

run-loop: $(BUILD_DIR)/loop
	./$(BUILD_DIR)/loop

run-calling-convention: $(BUILD_DIR)/calling_convention
	./$(BUILD_DIR)/calling_convention

clean:
	rm -rf $(BUILD_DIR)
