# AI Agent Instructions for DEC Repository

## Project Overview
The Data Exchange Component (DEC) is a Ruby-based data file routing and transformation system. Documentation is maintained in LaTeX format in `doc/tex/` with compiled PDFs and some Markdown references in `doc/md/`.

See [readme.md](readme.md) for OS dependencies and build instructions.

## Documentation Architecture

### LaTeX Source Files
- Location: `doc/tex/`
- Main file: `dec_sum_main.tex` (uses subfiles)
- Content modules:
  - `dec_introduction.tex` - Purpose & scope
  - `dec_configuration.tex` - Configuration structure and options
  - `dec_config_*.tex` - Configuration file references (general, interfaces, logging, pull, push)
  - `dec_reference_*.tex` - Reference documentation (commands, log messages, tests, workflows)
  - `dec_install*.tex` - Installation and update procedures
  - `dec_supported_*.tex` - Supported protocols and ADP formats
  - `dec_faq.tex` - Frequently asked questions
  - `dec_version_history.tex` - Version history
  - `dec_acronyms.tex` - Terminology
- Build system: Rake task `rake -f build_dec.rake dec:gendoc` generates PDF

### Markdown Documentation
- Location: `doc/md/`
- Current files: `dec_reference_commands.md`, `dec_reference_log_messages.md`
- **Purpose**: Markdown versions provide quick reference and improved online discoverability

## LaTeX-to-Markdown Conversion

### When to Convert
- When creating new quick-reference guides from detailed LaTeX documentation
- When adding documentation to README or inline help
- When maintaining parallel Markdown versions for web/GitHub display

### Tools & Methods

#### 1. **Pandoc (Recommended)**
Pandoc is the primary tool for LaTeX-to-Markdown conversion:

```bash
# Single file conversion
pandoc doc/tex/dec_reference_commands.tex -f latex -t markdown -o doc/md/dec_reference_commands.md

# Batch conversion with output directory
pandoc doc/tex/*.tex -f latex -t markdown -t markdown --output-dir doc/md/ --standalone
```

**Install Pandoc** (if needed):
```bash
# Ubuntu/Debian
sudo apt-get install pandoc

# macOS
brew install pandoc

# Or Ruby gem (included in most Docker builds)
gem install pandoc
```

#### 2. **Common Conversion Flags**
```bash
pandoc input.tex \
  -f latex \
  -t markdown \
  --wrap=none \              # Preserve line breaks
  --extract-media=./media \  # Extract embedded images
  -o output.md
```

### LaTeX-Specific Considerations

**Common Issues & Solutions:**
- **Subfiles**: The main file `dec_sum_main.tex` references subfiles via `\subfiles{}`. Pandoc should handle this, but may need explicit subfile processing.
- **Images**: Located in `doc/res/`. Use `--extract-media=doc/res/` to preserve image references.
- **Custom commands**: Check `dec_acronyms.tex` for project-specific LaTeX macros that may need manual adjustment in Markdown.
- **Cross-references**: LaTeX `\ref{}` and `\label{}` links will need to be converted to Markdown anchor syntax `[text](#anchor)`.
- **Tables and formatting**: Pandoc converts LaTeX tables to Markdown tables; review output for complex formatting.

### Workflow for New Markdown Files

1. **Identify source** in `doc/tex/` that needs Markdown version
2. **Run conversion**:
   ```bash
   pandoc doc/tex/SOURCE.tex -f latex -t markdown -o doc/md/SOURCE.md
   ```
3. **Post-process**:
   - Review image links in generated Markdown (update paths if needed)
   - Fix cross-references: Convert `\ref{label}` to `[](#section-name)` format
   - Adjust table formatting if complex
   - Update any project-specific terms or links
4. **Commit** both LaTeX source and generated Markdown
5. **Update** corresponding references in [readme.md](readme.md) or other docs

## Build System

See [build_dec.rake](build_dec.rake) for complete task definitions:

```bash
# Generate PDF documentation
rake -f build_dec.rake dec:gendoc

# Build DEC gem
rake -f build_dec.rake dec:build

# Install DEC gem
rake -f build_dec.rake dec:install
```

## Coding Conventions

### Ruby
- See [build_dec.rake](build_dec.rake) and [build_aux.rake](build_aux.rake) for build patterns
- Code organization: `code/dec/`, `code/aux/`, `code/drivers/`, etc.
- Testing: Run with `rake -f build_dec.rake dec:test`

### Documentation
- LaTeX uses `subfiles` package for modularity
- Acronyms and terminology centralized in `dec_acronyms.tex`
- Images in `doc/res/`
- Configuration files documented via XSD schemas in `schemas/`

## Common Development Tasks

### Task: Generate Markdown from all LaTeX docs
1. Ensure Pandoc is installed: `which pandoc` or `gem install pandoc`
2. Run: `pandoc doc/tex/*.tex -f latex -t markdown --output-dir doc/md/`
3. Review generated files in `doc/md/`
4. Commit changes

### Task: Update documentation after code changes
1. Edit source in `doc/tex/` (preferred) or `doc/md/` (if Markdown-only)
2. For PDF generation: `rake -f build_dec.rake dec:gendoc`
3. For Markdown sync: re-run Pandoc conversion
4. Test links in generated docs

### Task: Add new documentation section
1. Create new `.tex` file in `doc/tex/`
2. Add `\subfiles{new_section}` to `dec_sum_main.tex`
3. Test PDF build: `rake -f build_dec.rake dec:gendoc`
4. Generate Markdown: `pandoc doc/tex/new_section.tex -f latex -t markdown -o doc/md/new_section.md`

## Quick Reference

| Task | Command |
|------|---------|
| Check Pandoc installed | `pandoc --version` |
| Single LaTeX→Markdown | `pandoc input.tex -f latex -t markdown -o output.md` |
| Batch convert all | `pandoc doc/tex/*.tex -f latex -t markdown --output-dir doc/md/` |
| Generate PDF docs | `rake -f build_dec.rake dec:gendoc` |
| View generated docs | `doc/md/` (Markdown) or `doc/pdf/` (PDFs) |
