# Makefile for Typst project

# Variables
TYPST = typst
MAIN = main.typ
OUTPUT = main.pdf
SECTIONS = $(wildcard sections/*.typ)
FIGURES = $(wildcard figures/*.png)

# Default target
all: $(OUTPUT)

# Compile the main document
$(OUTPUT): $(MAIN) $(SECTIONS) $(FIGURES)
	$(TYPST) compile $(MAIN) $(OUTPUT)

# Watch for changes and recompile
watch:
	$(TYPST) watch $(MAIN) $(OUTPUT)

# Clean up generated files
clean:
	rm -f $(OUTPUT)

# Show project structure
tree:
	@tree -L 2 --charset=ascii

# Phony targets
.PHONY: all watch clean tree