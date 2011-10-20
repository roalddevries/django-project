:Dependencies: Python>=2.6

To install, run::

    createdb <project> # only first time, of course
    make               # creates virtualenv + dependencies, static and stages
    sudo make reload   # reloads apache and nginx; 'make restart' restarts both, 'make refresh' touches the wsgi file (and doesn't need sudo)


Project setup
=============

Configuration files for different stages (servers) go into `stages`. They are generated from the templates in `stages/templates`, filled with data from `stages/data.yaml` by `make_stages.py`. You shouldn't edit `make_stages.py`, but consider it a 3rd party app. For every stage, a directory is generated. On stage (server) X, `make_stages.py` should create a symlink `stages/current` to `stages/X`. The convention is to use the the domain as the stage name, e.g. `stages/trumpetcms_nl`.

Fixtures
--------

The fixture `initial_data.json` should be used for data that may be overwritten only. For other data (initial data that will be edited by the customer), use schema migrations. The easiest way to use schema migrations is having them load fixtures from a specific file.

CKEditor
--------

The javascript dependencies for CKEDitor are automatically installed by `make`. To use CKEditor in a template, put the following in there::

	<script type="text/javascript" src="{{ STATIC_URL }}js/jquery.js"></script>
	<script type="text/javascript" src="{{ STATIC_URL }}ckeditor/ckeditor.js"></script>
	<script type="text/javascript" src="{{ STATIC_URL }}ckeditor/adapters/jquery.js"></script>
	<script type="text/javascript">
		$(function() {
			$('textarea').ckeditor();
		});
	</script>

For use in the admin, put the following in `templates/admin/<app>/change_form.html`::

	{% extends "admin/change_form.html" %}

	{% block extrahead %}
		{{ block.super }}
		<script type="text/javascript" src="{{ STATIC_URL }}js/jquery.js"></script>
		<script type="text/javascript" src="{{ STATIC_URL }}ckeditor/ckeditor.js"></script>
		<script type="text/javascript" src="{{ STATIC_URL }}ckeditor/adapters/jquery.js"></script>
		<script type="text/javascript">
			$(function() {
				$('textarea').ckeditor();
			});
		</script>
	{% endblock %}

See the `CKEditor docs`_ and `Django admin docs`_ for a more detailed explanation.

.. _CKEditor docs:      http://docs.cksource.com/CKEditor_3.x/Developers_Guide/jQuery_Adapter
.. _Django admin docs:  https://docs.djangoproject.com/en/dev/ref/contrib/admin/#overriding-admin-templates
