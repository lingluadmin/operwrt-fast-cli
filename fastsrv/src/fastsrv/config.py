import yaml
import os
from jinja2 import Template

def render(patten, data):
    patten = patten.decode('utf-8')
    s = Template(patten)
    ret = s.render(data)
    return ret

def load_yaml(file):
    data = None
    with open(file, 'r') as f:
        data = yaml.load(f)
    return data

class Config:

    def __init__(self):
        src_dir = os.path.realpath(os.path.dirname(__file__))
        prj_dir = os.path.dirname(src_dir)
        prj_dir = os.path.dirname(prj_dir)
        self.config_dir = prj_dir + '/nginx-sites-config'
        pass

    def read_config(self, config_content, config_type, config_key):
        config = None
        if config_type == 'yaml':
            config = yaml.load(config_content)
        elif config_type == 'json':
            config = json.load(config_content)
        else:
            raise Exception('This config type is not supported now: ' +  config_type)

        return self._read_config(config, config_key)

    def read_config_from_local(self, config_file_name, config_key):

        file_name = self.config_dir + '/' + config_file_name + '.yaml'
        if not os.path.isfile(file_name):
            raise Exception('The config file is not existent: ' +  file_name)

        config = load_yaml(file_name)
        return self._read_config(config, config_key)

    def _read_config(self, config, key):
        data = config.copy()
        key_list = key.split('.')
        for sub_key in key_list:
            if sub_key not in data:
                raise Exception('Can not find config section for sub key:' +  sub_key)
            data = data[sub_key]
        return data
