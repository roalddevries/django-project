# TODO: don't unnecessarily do a syncdb and migrate and loaddata
# TODO: optionally have make handle createdb

JQUERY_VERSION = 1.6.4
CKEDITOR_VERSION = 3.6.2

SUBDIRS     = staticfiles $(addprefix staticfiles/,js) data locale

SUBPROJECTS = stages
PYBIN       = virtualenv/bin
PYTHON      = $(PYBIN)/python
PIP         = $(PYBIN)/pip
MANAGE      = $(PYBIN)/django-admin.py
RST2HTML    = $(PYBIN)/rst2html.py
PYPROGS     = $(PYTHON) $(PIP) $(MANAGE) $(RST2HTML)

export LANG                   = en_US.UTF-8
export LC_ALL                 = en_US.UTF-8
export DJANGO_SETTINGS_MODULE = stages.current.settings
export PYTHONPATH             = $(PWD)

.PHONY: initdb syncdb static patches refresh reload restart $(SUBPROJECTS)
.INTERMEDIATE: staticfiles/ckeditor_$(CKEDITOR_VERSION).tar.gz

# default target; what is made by 'make'
default: stages syncdb static patches

$(SUBDIRS):
	mkdir -p $@

$(SUBPROJECTS):
	$(MAKE) -C $@

tags:
	ctags -R --python-kinds=-i . $(VIRTUAL_ENV)/src/ $(VIRTUAL_ENV)/lib/python2.7/site-packages/django

stages/current: stages
	$(MAKE) -C $< $(@F)

refresh reload restart: stages
	$(MAKE) -C $< $@

virtualenv:
	virtualenv --no-site-packages virtualenv

$(PYPROGS): virtualenv requirements.txt
	$(PIP) install -r requirements.txt

syncdb: $(MANAGE) stages/current
	$< syncdb --noinput && $< migrate

staticfiles/js/jquery-$(JQUERY_VERSION).min.js: staticfiles/js
	curl http://code.jquery.com/jquery-$(JQUERY_VERSION).min.js > $@

staticfiles/js/jquery.js: staticfiles/js/jquery-$(JQUERY_VERSION).min.js
	cd $(@D) && ln -fs $(<F) $(@F)

staticfiles/ckeditor_$(CKEDITOR_VERSION).tar.gz:
	curl http://download.cksource.com/CKEditor/CKEditor/CKEditor%20$(CKEDITOR_VERSION)/ckeditor_$(CKEDITOR_VERSION).tar.gz > $@

staticfiles/ckeditor: staticfiles/ckeditor_$(CKEDITOR_VERSION).tar.gz
	tar -xzf $< -C $(<D)

staticfiles/project.html: PROJECT.rst $(RST2HTML) staticfiles
	$(RST2HTML) $< > $@

static: $(MANAGE) staticfiles/js/jquery.js staticfiles/ckeditor staticfiles/project.html
	$< collectstatic --noinput

stages:
	$(MAKE) -C $@

all_data.json: $(MANAGE)
	$< dumpdata --natural --all --indent=4 > $@

data/%.json: $(MANAGE) data
	$< dumpdata --natural $* --indent=4 > $@

locale/%/LC_MESSAGES/django.po: $(MANAGE) locale
	$< makemessages --locale=$*

locale/%/LC_MESSAGES/django.mo: $(MANAGE) locale/%/LC_MESSAGES/django.po
	$< compilemessages --locale=$*

stages/current/patches.diff: stages/current

# TODO: make a nicer dependency than PYTHON
patches: stages/current/patches.diff $(PYTHON)
	# diffs are created with `diff -ru <old> <new>`, and then manually editing paths
	patch -N -p0 < $< || :

