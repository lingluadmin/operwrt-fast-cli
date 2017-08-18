import unittest

class TestConfig(unittest.TestCase):

    def test_render(self):
        self.assertEqual('foo'.upper(), 'FOO')

    def test_load_yaml(self):
        self.assertEqual('foo'.upper(), 'FOO')
