PROJECT = project

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

/etc/%/sites-available/$(PROJECT): %.conf
	@echo PWD: $(PWD)
	ln -fs $(PWD)/current/$< $@

/etc/%/sites-enabled/$(PROJECT): /etc/%/sites-available/$(PROJECT)
	ln -fs $< $@

reload restart: /etc/apache2/sites-enabled/$(PROJECT) /etc/nginx/sites-enabled/$(PROJECT)
	nginx -t && /etc/init.d/nginx $@
	/etc/init.d/apache2 $@

