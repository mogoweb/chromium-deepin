#!/usr/bin/make -f

TARGETDIR = third_party
# Test dirs: cld_3 all Apache-2, breakpad mix of everything
#TARGETDIR = third_party/cld_3
#TARGETDIR = third_party/breakpad
TMPFILE = debian/copyright.tmp
COPY_IN = debian/copyright.in
COPY_OUT = debian/copyright

# exclude:
# - some obvious files that licensecheck picks up - something wrong with --check arg
# - m4 and configure can follow their project's license
# - chromium project text files that describe the project (DIR_METADATA, ...)
# - test data binaries, pdfs, images, ...
IGNORELIST := OWNER|OWNERS|README.*|LICENSE.*|license.*|License.*|COPYING.*|$\
	CREDITS.*|Changelog.*|Changes(\..*)?|$\
	MAINTAINERS.*|INSTALL.*|PRESUBMIT.*|RELEASE.*|AUTHORS.*|DIR_METADATA|$\
	MANIFEST.*|CMakeLists.*|CONTRIBUT.*|BUILD.*|DEPS|CODE_OF_CONDUCT.*|$\
	configure.*|requirements.txt|go\....|package.*\.json|\.json|\.settings|$\
	\.avif|\.bin|\.bmp|\.bz2|\.docx|\.dng|\.exif|\.flags|$\
	\.gz|\.gif|\.html|\.ico|\.m4|\.md|\.markdown|$\
	\.jp.?g|\.map|\.min\.js|\.riv|$\
	\.pb|\.pdf|\.png|\.pcf|\.rst|$\
	\.tmpl|\.ttc|\.webp|\.woff.?|\.xml|.y4m|$\
	phonenumbers/carrier/data/.*|$\
	fuzz/client_corpus_no_fuzzer_mode/.*|$\
	fuzz/server_corpus_no_fuzzer_mode/.*|$\
	hyb/hyph.*|$\
	uconv/samples/utf8/.*|$\
	/test/.*

all: generate clean

generate: checkcwd
	echo "1. generate 3p licenses (this takes a while)"
	licensecheck -r -m --copyright --shortname-scheme=debian --lines=40 --tail=0 \
		--ignore='$(IGNORELIST)' --copyright-delimiter=' ' \
		$(TARGETDIR) > $(TMPFILE).1
	echo "2. collect all 3p authors"
	cat $(TMPFILE).1 | cut -f3 | sort | uniq | grep -v "*No copyright*" > $(TMPFILE).2.auth
	# split ' / ', 'and later' into lines
	# convert <> to () and remove spaces to catch more duplicate emails
	# remove starting years: '1990', '1990-2000', '1990, 2000-2013'
	# Trim whitespace
	# empty lines
	cat $(TMPFILE).2.auth | \
		sed 's; / ;\n;g;s; and later: ;\n;' | \
		sed 's/</(/g;s/>/)/g;s/([[:space:]]/(/g;s/[[:space:]])/)/g' | \
		sed -E 's/(\{?\(?[[:digit:]]{0,4}\}?\)?-?[[:digit:]]{0,4},? ?)*(.*)/\2/' | \
		sed 's/^[[:space:]]*//;s/[\.,[:space:]]*$$//' | \
		sed '/^$$/d' | \
		sort --ignore-case | uniq --ignore-case > $(TMPFILE).2.auth.out
	echo "3. collect all 3p licenses"
	cat $(TMPFILE).1 | cut -f2 | sort | uniq | grep -v "UNKNOWN" > $(TMPFILE).3.lic
	# split up "and/or" if it's not part of a "with exception" line
	# Replace Expat and Unicode with their copyright names
	cat $(TMPFILE).3.lic | sed '/with/! s; \(and/\)\?or ;\n;g' | \
		sed 's/^Expat$$/MIT/;s/^Unicode-DFS.*/Unicode/' | \
		sed '/Libtool exception/d' | \
		sed '/Autoconf-data exception/d' | \
		sort | uniq > $(TMPFILE).3.lic.out
	echo "4. generate 3p out file"
	echo "Files: $(TARGETDIR)/*" > $(TMPFILE).out
	echo "Copyright:" >> $(TMPFILE).out
	cat $(TMPFILE).2.auth.out | sed 's/^/ /' >> $(TMPFILE).out
	echo "License: Various-3P-Licenses" >> $(TMPFILE).out
	cat $(TMPFILE).3.lic.out | sed 's/^/ /;s/$$/ and /' | sed '$$ s/ and//' >> $(TMPFILE).out
	echo "5. generate copyright file: $(COPY_OUT)"
	sed '/#--THIRDPARTY:BEGIN--#/ r $(TMPFILE).out' $(COPY_IN) > $(COPY_OUT)

clean: checkcwd
	rm -fv $(TMPFILE).*

countfiles:
	echo -n "Total files: "
	find -type f | wc -l
	echo -n "3p files: "
	find third_party/ -type f | wc -l
	echo Ignore list: '$(IGNORELIST)'

checkcwd:
	@if [ ! -d debian ]; then \
		echo "go to source dir (where you see debian/ and 'make -f debian/...')"; \
		exit 1; fi


.SILENT:
