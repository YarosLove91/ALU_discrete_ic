TOP_MODULE     = de2_115
VERILATOR_SRCS = src/$(TOP_MODULE).v src/alu_16.v
CPP_SRCS       = app.cpp
PY_SRCS        = app.py
OBJ_DIR        = obj_dir
EXE_NAME       = server
SAVE_NAME      = state.pkl

CXXFLAGS       = -O2 -std=c++17 -Wall -Wextra 
LDFLAGS        = -ljsoncpp -pthread -latomic

VERILATOR      = verilator
VERILATOR_FLAGS = --cc \
                  --exe \
                  --build \
                  -Wall \
                  --assert \
                  -Wno-fatal \
				  -Isrc

.PHONY: all build clean run print_help check_python

# Default target
print_help:
	@echo "Available targets:"
	@echo "  build    - Build the project"
	@echo "  run      - Build and run the server"
	@echo "  clean    - Clean build artifacts"
	@echo "  check_python - Verify Python version"

# Check Python version (>= 3.6 required)
check_python:
	@echo ">>> Checking Python version..."
	@python3 -c "import sys; exit(1) if sys.version_info < (3, 6) else exit(0)" || \
	 (echo "ERROR: Python 3.6+ required"; exit 1)
	@echo "Python version OK"

# Main build target
build: check_python $(EXE_NAME) 

$(EXE_NAME): $(VERILATOR_SRCS) $(CPP_SRCS)
	@echo ">>> [1/3] Verilating design..."
	$(VERILATOR) $(VERILATOR_FLAGS) \
		-CFLAGS "$(CXXFLAGS)" \
		-LDFLAGS "$(LDFLAGS)" \
		--top-module $(TOP_MODULE) \
		$(VERILATOR_SRCS) $(CPP_SRCS) \
		-o $(EXE_NAME)
	
	@echo ">>> [2/3] Building executable..."
	$(MAKE) -C $(OBJ_DIR) -f V$(TOP_MODULE).mk
	
	@echo ">>> [3/3] Copying executable..."
	cp $(OBJ_DIR)/$(EXE_NAME) .

# Run the server and GUI
run: build
	@echo ">>> Running..."
	./$(EXE_NAME)  & python3 $(PY_SRCS) 

# Clean build artifacts
clean:
	@echo ">>> Cleaning..."
	rm -rf $(OBJ_DIR) $(EXE_NAME) $(SAVE_NAME)

# Set default target
.DEFAULT_GOAL := print_help