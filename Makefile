VERSION=1.06

DESTDIR ?= /usr/local

BINDIR ?= $(DESTDIR)/sbin
SHARDIR ?= $(DESTDIR)/share
ETCDIR ?= $(DESTDIR)/etc

PKGNAME=bearwall
IPTABLES=iptables

BASEDIR ?= $(SHARDIR)/$(PKGNAME)
CONFDIR ?= $(ETCDIR)/$(PKGNAME)
MANDIR ?= $(SHARDIR)/man

RULESET := $(wildcard ruleset.d/*)
HOSTS := $(wildcard hosts.d/*)
CLASSES := $(wildcard classes.d/*)
INTERFACES := $(wildcard interfaces.d/*)
SUPPORT := $(wildcard support/*)

all: build-firewall

build-firewall:
	@sed -e s#@BASEDIR@#$(BASEDIR)#g -e s#@CONFDIR@#$(CONFDIR)#g \
		src/firewall.in \
		>src/$(PKGNAME)
	@sed -e s#@BASEDIR@#$(subst -,\\\\-,$(BASEDIR))#g \
		-e s#@CONFDIR@#$(subst -,\\\\-,$(CONFDIR))#g \
		-e s#@PKGNAME@#$(subst -,\\\\-,$(PKGNAME))#g \
		doc/firewall.8.in \
		>doc/$(PKGNAME).8

clean:
	@rm -f src/$(PKGNAME) doc/$(PKGNAME).8
	@rm -f $(PKGNAME)-*.tar.*

install-bin: all

	install -D --group=root --mode=755 --owner=root \
		src/$(PKGNAME) $(DESTDIR)$(BINDIR)/$(PKGNAME)

	install -d --group=root --mode=755 --owner=root \
		$(DESTDIR)$(BASEDIR)/ruleset.d
	for i in $(RULESET); \
		do install -D --group=root --mode=644 --owner=root \
		$$i $(DESTDIR)$(BASEDIR)/$$i; \
		done

	install -d --group=root --mode=755 --owner=root \
		$(DESTDIR)$(BASEDIR)/support
	for i in $(SUPPORT); \
		do install -D --group=root --mode=644 --owner=root \
		$$i $(DESTDIR)$(BASEDIR)/$$i; \
		done

install-conf: all

	install -d --group=root --mode=755 --owner=root \
		$(DESTDIR)$(CONFDIR)/hosts.d
	for i in $(HOSTS); \
		do install -D --group=root --mode=744 --owner=root \
		$$i $(DESTDIR)$(CONFDIR)/$$i; \
		done

	install -d --group=root --mode=755 --owner=root \
		$(DESTDIR)$(CONFDIR)/classes.d
	for i in $(CLASSES); \
		do install -D --group=root --mode=644 --owner=root \
		$$i $(DESTDIR)$(CONFDIR)/$$i; \
		done

	install -d --group=root --mode=755 --owner=root \
		$(DESTDIR)$(CONFDIR)/interfaces.d
	for i in $(INTERFACES); \
		do install -D --group=root --mode=644 --owner=root \
		$$i $(DESTDIR)$(CONFDIR)/$$i; \
		done

install-doc: all
	
	install -d --group=root --mode=755 --owner=root \
		$(DESTDIR)$(MANDIR)/man8
	install --group=root --mode=644 --owner=root \
		doc/$(PKGNAME).8 $(DESTDIR)$(MANDIR)/man8
	install --group=root --mode=644 --owner=root \
		doc/$(PKGNAME).8 $(DESTDIR)$(MANDIR)/man8

install: install-bin install-conf install-doc

.PHONY: clean all build-firewall install install-bin install-conf install-doc

#---#---#---#
#
# All text after the marker above is removed during a "make release" as we
# put the revision info into the file at release time and it doesn't need 
# to be done each build
#

all: build-rev

build-rev: build-firewall
	@sed -e 's#VERSION=".*"#VERSION="$(VERSION)"#g' \
		-e 's#REVISION=".*"#REVISION="$(r)"#g' \
		src/$(PKGNAME) > src/$(PKGNAME).$$
	@mv src/$(PKGNAME).$$ src/$(PKGNAME)

r := $(shell ./revision-info.sh)
tmpdir := $(shell mktemp -ud)
pwd := $(shell pwd)

release:
	@./revision-info.sh -c
	@mkdir -p $(tmpdir)/$(PKGNAME)-$(VERSION)
	@git archive master | tar -x -C $(tmpdir)/$(PKGNAME)-$(VERSION)
	@sed -e 's#VERSION=".*"#VERSION="$(VERSION)"#g' \
		-e 's#REVISION=".*"#REVISION="$(r)"#g' \
		$(tmpdir)/$(PKGNAME)-$(VERSION)/src/firewall.in \
		> $(tmpdir)/$(PKGNAME)-$(VERSION)/src/$(PKGNAME).$$
	@sed --in-place '/#---#---#---#/,$$d' \
		$(tmpdir)/$(PKGNAME)-$(VERSION)/Makefile
	@mv $(tmpdir)/$(PKGNAME)-$(VERSION)/src/$(PKGNAME).$$ \
		$(tmpdir)/$(PKGNAME)-$(VERSION)/src/firewall.in
	@cd $(tmpdir); tar cjf $(pwd)/$(PKGNAME)-$(VERSION).tar.bz2 \
		$(PKGNAME)-$(VERSION)/
	@cd $(tmpdir); tar czf $(pwd)/$(PKGNAME)-$(VERSION).tar.gz \
		$(PKGNAME)-$(VERSION)/
	@rm -rf $(tmpdir) $(tmpdir)/revision-info.sh

.PHONY: release build-rev
