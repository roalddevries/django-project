from __future__ import with_statement
import glob, os, tempita, yaml

with open('data.yaml') as input:
    data = yaml.load(input.read())
    # create all stages
    for stage_name, stage in data['stages'].iteritems():
        try:
            os.mkdir(stage_name)
        except OSError:
            pass
        open(os.path.join(stage_name, '__init__.py'), 'w').close()
        # create all settings files for this stage
        for template_file in glob.glob(os.path.join('templates', '*.tmpl')):
            template = tempita.Template(open(template_file).read())
            output_file = os.path.join(stage_name, os.path.basename(template_file)[:-5])
            with open(output_file, 'w') as output:
                context_dict = dict(data, stage=stage_name, **stage)
                substituted = template.substitute(**context_dict)
                output.write(substituted)


