SHELL = /bin/sh
NULLCMD = :
RUNCMD = $(SHELL)
exec = exec

#### Start of system configuration section. ####

srcdir = .
top_srcdir = $(srcdir)
hdrdir = $(srcdir)/include

CC = gcc
YACC = bison
PURIFY =
AUTOCONF = autoconf

MKFILES = Makefile
BASERUBY = ruby

prefix = /usr/local
exec_prefix = ${prefix}
bindir = ${exec_prefix}/bin
sbindir = ${exec_prefix}/sbin
libdir = ${exec_prefix}/lib
libexecdir = ${exec_prefix}/libexec
datarootdir = ${prefix}/share
datadir = ${datarootdir}
arch = i686-linux
sitearch = i686-linux
sitedir = ${libdir}/${RUBY_INSTALL_NAME}/site_ruby
ruby_version = 1.9.1

TESTUI = console
TESTS =
RDOCTARGET = install-doc

EXTOUT = .ext
RIDATADIR = $(DESTDIR)$(datadir)/ri/$(MAJOR).$(MINOR)/system
arch_hdrdir = $(EXTOUT)/include/$(arch)
VPATH = $(arch_hdrdir)/ruby:$(hdrdir)/ruby:$(srcdir)/enc:$(srcdir)/missing

empty =
OUTFLAG = -o $(empty)
COUTFLAG = -o $(empty)
CFLAGS =  ${cflags} 
cflags = ${optflags} ${debugflags} ${warnflags}
optflags = -O2
debugflags = -g
warnflags = -Wall -Wno-parentheses
XCFLAGS = -I. -I$(arch_hdrdir) -I$(hdrdir) -I$(srcdir)  -DRUBY_EXPORT
CPPFLAGS =  $(DEFS) ${cppflags}
LDFLAGS =  $(CFLAGS) -L.  -rdynamic -Wl,-export-dynamic
EXTLDFLAGS = 
XLDFLAGS =  $(EXTLDFLAGS)
EXTLIBS = 
LIBS = -lpthread -lrt -ldl -lcrypt -lm  $(EXTLIBS)
MISSING =  ${LIBOBJDIR}strlcpy.o ${LIBOBJDIR}strlcat.o 
LDSHARED = ${CC} -shared
DLDFLAGS =  $(EXTLDFLAGS) 
SOLIBS = 
MAINLIBS = 
ARCHMINIOBJS = dln.o
BUILTIN_ENCOBJS =  ascii.$(OBJEXT) us_ascii.$(OBJEXT) unicode.$(OBJEXT) utf_8.$(OBJEXT)
BUILTIN_TRANSSRCS =  newline.c
BUILTIN_TRANSOBJS =  newline.$(OBJEXT)

RUBY_INSTALL_NAME=ruby
RUBY_SO_NAME=$(RUBY_INSTALL_NAME)
EXEEXT = 
PROGRAM=$(RUBY_INSTALL_NAME)$(EXEEXT)
RUBY = $(RUBY_INSTALL_NAME)
MINIRUBY = ./miniruby$(EXEEXT) -I$(srcdir)/lib -I$(EXTOUT)/common -I./- -r$(srcdir)/ext/purelib.rb $(MINIRUBYOPT)
RUNRUBY = $(MINIRUBY) $(srcdir)/runruby.rb --extout=$(EXTOUT) $(RUNRUBYOPT) --

#### End of system configuration section. ####

MAJOR=	1
MINOR=	9
TEENY=	1

LIBRUBY_A     = lib$(RUBY_SO_NAME)-static.a
LIBRUBY_SO    = lib$(RUBY_SO_NAME).so.$(MAJOR).$(MINOR).$(TEENY)
LIBRUBY_ALIASES= lib$(RUBY_SO_NAME).so
LIBRUBY	      = $(LIBRUBY_A)
LIBRUBYARG    = $(LIBRUBYARG_STATIC)
LIBRUBYARG_STATIC = -Wl,-R -Wl,$(libdir) -L$(libdir) -l$(RUBY_SO_NAME)-static
LIBRUBYARG_SHARED = -Wl,-R -Wl,$(libdir) -L$(libdir) -l$(RUBY_SO_NAME)

THREAD_MODEL  = pthread

PREP          = miniruby$(EXEEXT)
ARCHFILE      = 
SETUP         =
EXTSTATIC     = 
SET_LC_MESSAGES = env LC_MESSAGES=C

MAKEDIRS      = mkdir -p
CP            = cp
MV            = mv
RM            = rm -f
RMDIRS        = $(top_srcdir)/tool/rmdirs
RMALL         = rm -fr
NM            = 
AR            = ar
ARFLAGS       = rcu
RANLIB        = ranlib
AS            = as
ASFLAGS       = 
IFCHANGE      = $(srcdir)/tool/ifchange
SET_LC_MESSAGES = env LC_MESSAGES=C
OBJDUMP       = objdump
OBJCOPY       = objcopy
VCS           = git
VCSUP         = $(VCS) pull $(GITPULLOPTIONS)

OBJEXT        = o
ASMEXT        = S
DLEXT         = so
MANTYPE	      = doc

INSTALLED_LIST= .installed.list

MKMAIN_CMD    = mkmain.sh
#### End of variables

all:

.DEFAULT: all

# Prevent GNU make v3 from overflowing arg limit on SysV.
.NOEXPORT:

miniruby$(EXEEXT):
		@-if test -f $@; then mv -f $@ $@.old; $(RM) $@.old; fi
		$(PURIFY) $(CC) $(LDFLAGS) $(XLDFLAGS) $(MAINLIBS) $(MAINOBJ) $(MINIOBJS) $(COMMONOBJS) $(DMYEXT) $(ARCHFILE) $(LIBS) $(OUTFLAG)$@

$(PROGRAM):
		@$(RM) $@
		$(PURIFY) $(CC) $(LDFLAGS) $(XLDFLAGS) $(MAINLIBS) $(MAINOBJ) $(EXTOBJS) $(LIBRUBYARG) $(LIBS) $(OUTFLAG)$@

# We must `rm' the library each time this rule is invoked because "updating" a
# MAB library on Apple/NeXT (see --enable-fat-binary in configure) is not
# supported.
$(LIBRUBY_A):
		@$(RM) $@
		$(AR) $(ARFLAGS) $@ $(OBJS) $(DMYEXT)
		@-$(RANLIB) $@ 2> /dev/null || true

$(LIBRUBY_SO):
		@-$(PRE_LIBRUBY_UPDATE)
		$(LDSHARED) $(DLDFLAGS) $(OBJS) $(DLDOBJS) $(SOLIBS) $(OUTFLAG)$@
		-$(OBJCOPY) -w -L 'Init_*' $@
		@-$(MINIRUBY) -e 'ARGV.each{|link| File.delete link if File.exist? link; \
						  File.symlink "$(LIBRUBY_SO)", link}' \
				$(LIBRUBY_ALIASES) || true

fake: $(arch)-fake.rb
$(arch)-fake.rb: config.status
		 @./config.status --file=$@:$(srcdir)/template/fake.rb.in

Makefile:	$(srcdir)/Makefile.in $(srcdir)/enc/Makefile.in

$(MKFILES): config.status
		MAKE=$(MAKE) $(SHELL) ./config.status
		@{ \
		    echo "all:; -@rm -f conftest.mk"; \
		    echo "conftest.mk: .force; @echo AUTO_REMAKE"; \
		    echo ".force:"; \
		} > conftest.mk || exit 1; \
		$(MAKE) -f conftest.mk | grep '^AUTO_REMAKE$$' >/dev/null 2>&1 || \
		{ echo "Makefile updated, restart."; exit 1; }

uncommon.mk: $(srcdir)/common.mk
		sed 's/{\$$([^(){}]*)[^{}]*}//g' $< > $@

config.status:	$(srcdir)/configure $(srcdir)/enc/Makefile.in
		MINIRUBY="$(MINIRUBY)" $(SHELL) ./config.status --recheck

$(srcdir)/configure: $(srcdir)/configure.in
		cd $(srcdir) && $(AUTOCONF)

# Things which should be considered:
# * with gperf v.s. without gperf
# * ./configure v.s. ../ruby/configure
# * GNU make v.s. HP-UX make	# HP-UX make invokes the action if lex.c and keywords has same mtime.
# * svn checkout generate a file with mtime as current time
# * XFS has a mtime with fractional part
lex.c: defs/keywords
	@\
	if cmp -s $(srcdir)/defs/lex.c.src $?; then \
	  set -x; \
	  cp $(srcdir)/lex.c.blt $@; \
	else \
	  set -x; \
	  gperf -C -p -j1 -i 1 -g -o -t -N rb_reserved_word -k1,3,$$ $? > $@.tmp && \
	  mv $@.tmp $@ && \
	  cp $? $(srcdir)/defs/lex.c.src && \
	  cp $@ $(srcdir)/lex.c.blt; \
	fi

.c.o:
	$(CC) $(CFLAGS) $(XCFLAGS) $(CPPFLAGS) $(COUTFLAG)$@ -c $<

.s.o:
	$(AS) $(ASFLAGS) -o $@ $<

.c.S:
	$(CC) $(CFLAGS) $(XCFLAGS) $(CPPFLAGS) $(COUTFLAG)$@ -S $<

clean-local::
	@$(RM) ext/extinit.c ext/extinit.$(OBJEXT) ext/ripper/y.output

distclean-local::
	@$(RM) ext/config.cache $(RBCONFIG)
	@-$(RM) run.gdb
	@-$(RM) $(INSTALLED_LIST) $(arch_hdrdir)/ruby/config.h
	@-$(RMDIRS) $(arch_hdrdir)/ruby

distclean-rdoc:
	@$(RMALL) $(RDOCOUT:/=\)

clean-ext distclean-ext realclean-ext::
	@set dummy ${EXTS}; shift; \
	if test "$$#" = 0; then \
	    set dummy `find ext -name Makefile | sed 's:^ext/::;s:/Makefile$$::' | sort`; \
	    shift; \
	fi; \
	for dir; do \
	    [ -f "ext/$$dir/Makefile" ] || continue; \
	    echo $(@:-ext=)ing "$$dir"; \
	    (cd "ext/$$dir" && exec $(MAKE) $(MFLAGS) $(@:-ext=)) && \
	    case "$@" in \
	    *distclean-ext*|*realclean-ext*) \
		$(RMDIRS) "ext/$$dir";; \
	    esac; \
	done

distclean-ext realclean-ext::
	@-rmdir ext 2> /dev/null || true

ext/extinit.$(OBJEXT): ext/extinit.c $(SETUP)
	$(CC) $(CFLAGS) $(XCFLAGS) $(CPPFLAGS) $(COUTFLAG)$@ -c ext/extinit.c

up::
	@LC_TIME=C cd "$(srcdir)" && $(VCSUP)

update-rubyspec: 
	@if [ -d $(srcdir)/spec/mspec ]; then \
	  cd $(srcdir)/spec/mspec; \
	  echo updating mspec ...; \
	  git pull; \
	  cd ../..; \
	else \
	  echo retrieving mspec ...; \
	  git clone $(MSPEC_GIT_URL) $(srcdir)/spec/mspec; \
	fi
	@if [ -d $(srcdir)/spec/rubyspec ]; then \
	  cd $(srcdir)/spec/rubyspec; \
	  echo updating rubyspec ...; \
	  git pull; \
	else \
	  echo retrieving rubyspec ...; \
	  git clone $(RUBYSPEC_GIT_URL) $(srcdir)/spec/rubyspec; \
	fi

test-rubyspec:
	@if [ ! -d $(srcdir)/spec/rubyspec ]; then echo No rubyspec here.  make update-rubyspec first.; exit 1; fi
	$(RUNRUBY) $(srcdir)/spec/mspec/bin/mspec -B $(srcdir)/spec/default.mspec $(MSPECOPT)

INSNS	= opt_sc.inc optinsn.inc optunifs.inc insns.inc insns_info.inc \
	  vmtc.inc vm.inc

$(INSNS):
	@$(RM) $(PROGRAM)
	$(BASERUBY) -Ks $(srcdir)/tool/insns2vm.rb $(INSNS2VMOPT) $@

node_name.inc:
	$(BASERUBY) -n $(srcdir)/tool/node_name.rb $? > $@

known_errors.inc:
	$(BASERUBY) $(srcdir)/tool/generic_erb.rb -c -o $@ $(srcdir)/template/known_errors.inc.tmpl $(srcdir)/defs/known_errors.def

miniprelude.c:
	$(BASERUBY) -I$(srcdir) $(srcdir)/tool/compile_prelude.rb $(srcdir)/prelude.rb $@

newline.c: 
	$(BASERUBY) "$(srcdir)/tool/transcode-tblgen.rb" -vo newline.c $(srcdir)/enc/trans/newline.trans

distclean-local::; @$(RM) GNUmakefile uncommon.mk
