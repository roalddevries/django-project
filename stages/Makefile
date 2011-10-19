PYBIN   = virtualenv/bin
PYLIB   = virtualenv/lib/python2.7/site-packages
PYSRC   = virtualenv/src
PYTHON  = $(PYBIN)/python
PIP     = $(PYBIN)/pip
TEMPITA = $(PYSRC)/tempita-tip
PYDEPS  = $(PYTHON) $(PIP) $(TEMPITA)

.PHONY: reload restart

default: make_stages.py $(PYTHON) data.yaml templates/* __init__.py
	$(PYTHON) $<

virtualenv:
	virtualenv --no-site-packages $@

$(PYDEPS): requirements.txt virtualenv
	$(PIP) install -r $<

__init__.py:
	touch $@

current:
	test -L $@ || { read -p 'stage: ' STAGE; ln -sf $$STAGE $@; }

refresh: current
	touch $</wsgi.py

/etc/%/sites-available/barteryourbusiness: %.conf
	@echo PWD: $(PWD)
	ln -fs /Users/apple/Projects/barteryourbusiness/stages/current/$< $@

/etc/%/sites-enabled/barteryourbusiness: /etc/%/sites-available/barteryourbusiness
	ln -fs $< $@

reload restart: /etc/apache2/sites-enabled/barteryourbusiness /etc/nginx/sites-enabled/barteryourbusiness
	nginx -t && /etc/init.d/nginx $@
	/etc/init.d/apache2 $@

