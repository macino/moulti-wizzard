.PHONY: install uninstall check help

PREFIX ?= $(HOME)/.local
BINDIR ?= $(PREFIX)/bin
SCRIPT_NAME = moulti-wizard

help:
	@echo "moulti-wizard installation targets:"
	@echo ""
	@echo "  make install       Install moulti-wizard to $(BINDIR)"
	@echo "  make uninstall     Remove moulti-wizard from $(BINDIR)"
	@echo "  make check         Verify dependencies are installed"
	@echo "  make help          Show this message"
	@echo ""
	@echo "Environment variables:"
	@echo "  PREFIX=$(PREFIX)        Base installation directory"
	@echo "  BINDIR=$(BINDIR)        Where the script is installed"

install: check
	mkdir -p "$(BINDIR)"
	install -m 0755 "$(SCRIPT_NAME)" "$(BINDIR)/$(SCRIPT_NAME)"
	@echo "✓ $(SCRIPT_NAME) installed to $(BINDIR)/$(SCRIPT_NAME)"
	@echo ""
	@echo "Add to PATH if needed:"
	@echo "  export PATH=$(BINDIR):\$$PATH"

uninstall:
	rm -f "$(BINDIR)/$(SCRIPT_NAME)"
	@echo "✓ $(SCRIPT_NAME) removed"

check:
	@./check-deps.sh
