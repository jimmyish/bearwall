DESTDIR ?=

BINDIR ?= /usr/local/sbin
SHARDIR ?= /usr/local/share
ETCDIR ?= /usr/local/etc

PKGNAME=linuxserver-firewall
IPTABLES=iptables

BASEDIR ?= $(SHARDIR)/$(PKGNAME)
CONFDIR ?= $(ETCDIR)/$(PKGNAME)
MANDIR ?= $(SHARDIR)/man

RULESET := $(wildcard ruleset.d/*)
HOSTS := $(wildcard hosts.d/*)
CLASSES := $(wildcard classes.d/*)
INTERFACES := $(wildcard interfaces.d/*)
SUPPORT := $(wildcard support/*)

all: 
	@sed -e s#@BASEDIR@#$(BASEDIR)#g -e s#@CONFDIR@#$(CONFDIR)#g \
		src/firewall.in \
		>src/firewall
	@sed -e s#@BASEDIR@#$(subst -,\\\\-,$(BASEDIR))#g \
		-e s#@CONFDIR@#$(subst -,\\\\-,$(CONFDIR))#g \
		doc/linuxserver-firewall.8.in \
		>doc/linuxserver-firewall.8

clean:
	@rm -f src/firewall doc/linuxserver-firewall.8

install-bin: all

	install -D --group=root --mode=755 --owner=root \
		src/firewall $(DESTDIR)$(BINDIR)/firewall

	install -d --group=root --mode=755 --owner=root \
		$(DESTDIR)$(BASEDIR)/ruleset.d
	for i in $(RULESET); \
		do install -D --group=root --mode=644 --owner=root \
		$$i $(DESTDIR)$(BASEDIR)/$$i; \
		done
		
	install -d --group=root --mode=755 --owner=root \
		$(DESTDIR)$(BASEDIR)/support
	for i in $(SUPPORT); \
		do install -D --group=root --mode=744 --owner=root \
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
		doc/firewall.8 $(DESTDIR)$(MANDIR)/man8
	install --group=root --mode=644 --owner=root \
		doc/linuxserver-firewall.8 $(DESTDIR)$(MANDIR)/man8

install: install-bin install-conf install-doc
