import yaml
import socket
import os
import shutil
import sys
from jinja2 import Template

CONFIG_FILE='/fastsrv/sites-config/sites-config.yaml'
TEMPLATES_DIR='/fastsrv/templates'
OUTPUT_DIR='/fastsrv/output'

class AppConfigRender:
    def __init__(self, app, basic_data):
        self.app = app
        data = dict(basic_data)
        data['app'] = app
        self.data = data
    def __render_str(self, str):
        s = Template(str)
        val = s.render(self.data)
        return val
    def __render_template_file(self, template_file):
        if not os.path.isfile(template_file):
            return
        dir = os
        file = self.nginx_conf_dir + '/' + os.path.basename(template_file)
        print 'write to %s' % file
        with open(template_file, 'r') as f:
            patten = f.read()
            result = self.__render_str(patten)
            with open(file, 'w') as fw:
                fw.write(result)
    def __render_vars(self, config):
        vars = config['vars']
        '''
        for key, val in vars.items():
            val = self.__render_str(val)
            vars[key] = val
        '''
        data = self.data.copy()
        data.update(vars)
        self.data = data
    def __prepare_dir(self):
        dir = OUTPUT_DIR + '/' + self.app
        if not os.path.exists(dir):
            os.makedirs(dir)
        else:
            shutil.rmtree(dir)
            os.makedirs(dir)
        self.nginx_conf_dir = dir
    def render(self, config):
        self.__prepare_dir()
        self.__render_vars(config)
        for template_file in config['nginx-templates']:
            template_file = TEMPLATES_DIR + '/' + template_file
            template_file = self.__render_str(template_file)
            self.__render_template_file(template_file)

class Updater:
    def prepare_basic_data(self):
        env = os.environ
        shutil.rmtree(OUTPUT_DIR, ignore_errors=True)
        # mix env
        data = {}
        data.update(env)
        self.basic_data = data
    def load_yaml(self, file):
        data = None
        with open(file, 'r') as f:
            data = yaml.load(f)
        return data
    def run(self):
        self.prepare_basic_data()
        yaml = self.load_yaml(CONFIG_FILE)
        app = 'all'
        if app in yaml:
            self.render_app(app, yaml[app])
        elif app == 'all':
            for app_key, item in yaml.items():
                self.render_app(app_key, yaml[app_key])
    def render_app(self, app, config):
        render = AppConfigRender(app, self.basic_data)
        render.render(config)
if __name__ == '__main__':
    updater = Updater()
    updater.run()
