# Rules to generate the files that need to go into the ELPA package.

# Files we need to auto-generate for elpa:
#   README
#   ChangeLog
#   tex-site.el
#   doc: preview-dtxdoc.texi
#   doc: version.texi
#   latex: prauctex.cfg
#   latex: prauctex.def
#   latex: prcounters.def
#   latex: preview.sty
#   latex: prfootnotes.def
#   latex: prlyx.def
#   latex: prshowbox.def
#   latex: prshowlabels.def
#   latex: prtightpage.def
#   latex: prtracingall.def

EMACSBIN=emacs
EMACS=$(EMACSBIN) --batch -q -no-site-file -no-init-file -l lpath.el
MAKEINFO=makeinfo
INSTALL_INFO=install-info
PERL=perl

MANUALS=auctex preview-latex
INFO_FILES=$(MANUALS:=.info)

TEXMFGEN:=$(shell sed -n 's/^%<installer>.*file[{]\([^}.]*\.[sdc][tef][yfg]\)[}].*/\1/p' latex/preview.dtx)
LATEX_FILES:=$(patsubst %, latex/%, $(shell echo $$(echo "$(TEXMFGEN)")))

MAIN_GENERATED_FILES=README 		\
		tex-site.el		\
		doc/version.texi	\
		doc/preview-dtxdoc.texi	\
		$(LATEX_FILES)

ALL_GENERATED_FILES=$(MAIN_GENERATED_FILES)	\
		dir				\
		$(INFO_FILES)

# Generate & compile everything including the manuals below doc/.
all: $(ALL_GENERATED_FILES) compile auctex-autoloads.el

compile: $(patsubst %.el,%.elc,$(wildcard *.el style/*.el))

# If we were depending on emacs 29.1, we could simply use
# loaddefs-generate.  If we were depending on 28.1, we could still use
# update-directory-autoloads...
AUTOLOAD=--eval '\
(let* ((autoload-file (expand-file-name "$@")) \
       (autoload-file-dir (file-name-directory autoload-file))) \
  (if (fboundp `loaddefs-generate) \
      (loaddefs-generate autoload-file-dir autoload-file \
                         (list "tex-wizard.el") \
                         "(add-to-list `load-path\n\
                                       (directory-file-name\n\
                                         (file-name-directory load-file-name)))")\
    (mapc (lambda (file) \
            (update-file-autoloads file nil autoload-file)) \
          command-line-args-left)) \
  (save-buffers-kill-emacs t))'

auctex-autoloads.el:
	rm -f $@
	$(EMACS) $(AUTOLOAD) $(wildcard *.el)

%.elc: %.el
	$(EMACS) -f batch-byte-compile $<

# Generate everything but don't compile or build the docs.  The docs
# will be built on elpa due to :doc ("doc/auctex.texi"
# "doc/preview-latex.texi") in the auctex recipe in elpa-packges and
# compiling is done locally.
elpa: $(MAIN_GENERATED_FILES) ChangeLog

# We want the tex-site.el target to be always run so that the version
# (especially the release version grabbed from the top of the git log)
# is correct.
.PHONY: tex-site.el

clean:
	rm -f $(ALL_GENERATED_FILES) \
		$(wildcard *.elc style/*.elc) \
		auctex-autoloads.el \
		$(DYNVARSFILES)

# Copied&adapted from doc/Makefile.in.
MAKEINFO_PLAIN=$(MAKEINFO) -D rawfile --no-headers
README: doc/intro.texi doc/preview-readme.texi doc/macros.texi
	(cd doc; $(MAKEINFO_PLAIN) intro.texi --output -) >$@
	(cd doc; $(MAKEINFO_PLAIN) preview-readme.texi --output -) >> $@

# Committer date of HEAD.
AUCTEXDATE:=$(shell (git log -n1 --pretty=tformat:"%ci" 2>/dev/null \
                     || date +"%Y-%m-%d %T") 		       	    \
                    | sed -re 's/ /_/' -e 's/ .*//')
# Extract the version number from the diff line "+;; Version: 14.0.4" of
# the commit HEAD which is only filled when we did a release in the last
# commit.
THISVERSION:=$(shell git show HEAD -- auctex.el 2>/dev/null \
	| sed -nre 's/[+];; Version: ([0-9]+.[0-9]+.[0-9]+)/\1/p')
# Extract the last released version number from `auctex.el`.
LASTVERSION:=$(shell grep "^;; Version:" auctex.el \
                     | sed -nre 's/;; Version: ([0-9]+.[0-9]+.[0-9]+)/\1/p;q')
AUCTEXVERSION:=$(if $(THISVERSION),$(THISVERSION),$(LASTVERSION).$(AUCTEXDATE))

tex-site.el: tex-site.el.in
	sed -e 's|@lisppackagelispdir@|(file-name-directory load-file-name)|'\
	    -e 's|@lisppackagedatadir@|(file-name-directory load-file-name)|'\
	    -e 's|@lispautodir@|(if (file-writable-p "/usr/local/var/auctex") "/usr/local/var/auctex" "~/.emacs.d/auctex")|'\
	    -e 's|@AUCTEXVERSION@|$(AUCTEXVERSION)|'\
	    -e 's|@AUCTEXDATE@|$(AUCTEXDATE)|'\
	    $< >$@

doc/version.texi:
	echo @set VERSION $(AUCTEXVERSION) >$@
	echo @set UPDATED $(AUCTEXDATE) >>$@

ChangeLog:
	rm -f $@
	./build-aux/gitlog-to-auctexlog && cat ChangeLog.1 >> $@

# Copied&adapted from doc/Makefile.in.
doc/preview-dtxdoc.texi: latex/preview.dtx doc/preview-dtxdoc.pl
	$(PERL) doc/preview-dtxdoc.pl latex/preview.dtx $@

# Copied&adapted from doc/Makefile.in.
TEXI_SOURCES:=$(wildcard doc/*.texi) doc/version.texi doc/preview-dtxdoc.texi
$(INFO_FILES): %.info: $(TEXI_SOURCES)
	cd doc; $(MAKEINFO) --no-split $*.texi

dir: $(INFO_FILES)
	for f in $(INFO_FILES); do $(INSTALL_INFO) --info-dir=doc doc/$$f; done

$(LATEX_FILES): latex/preview.dtx latex/bootstrap.ins
	cd latex; $(TEX) '\nonstopmode \input bootstrap.ins'
	cd latex; $(TEX) '\nonstopmode \input preview-mk.ins'

DYNVARSFILES = *.dynvars style/*.dynvars auctex-dynvars
dynvars-check:
	rm -f $(wildcard *.elc) $(wildcard style/*.elc) $(DYNVARSFILES)
	EMACS_GENERATE_DYNVARS=1 $(EMACS) -f batch-byte-compile \
		$(wildcard *.el) $(wildcard style/*.el) \
		> /dev/null 2>&1
	cat *.dynvars style/*.dynvars > auctex-dynvars
	rm -f $(wildcard *.elc) $(wildcard style/*.elc)
	EMACS_DYNVARS_FILE=auctex-dynvars $(EMACS) \
		-f batch-byte-compile \
		$(wildcard *.el) $(wildcard style/*.el)
