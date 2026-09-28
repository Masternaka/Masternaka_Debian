import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]

class InstallTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.home = Path(self.tmp.name) / 'user with spaces'
        self.home.mkdir()
        self.env = {**os.environ, 'HOME': str(self.home), 'DISPLAY': ''}

    def tearDown(self):
        self.tmp.cleanup()

    def deploy(self):
        return subprocess.run(['bash', '-eu', '-c', 'source "$1/lib/install.sh"; deploy_config "$1"', 'test', str(ROOT)], env=self.env, check=True, capture_output=True, text=True)

    def test_dry_run_no_writes(self):
        subprocess.run(['bash', str(ROOT/'install.sh'), '--dry-run'], env=self.env, check=True, capture_output=True)
        self.assertEqual(list(self.home.iterdir()), [])

    def test_repeat_deploy_preserves_previous_files(self):
        self.deploy()
        target = self.home/'.config/i3'
        (target/'my-custom-file').write_text('precious settings')
        self.deploy()
        backups = list((self.home/'.local/state/masternaka-debian/backups').glob('*/i3/my-custom-file'))
        self.assertEqual(len(backups), 1)
        self.assertEqual(backups[0].read_text(), 'precious settings')
        self.assertFalse((target/'my-custom-file').exists())
        self.assertTrue(os.access(target/'polybar/polybar-i3', os.X_OK))
        self.assertTrue(os.access(target/'scripts/autostart.sh', os.X_OK))

    def test_symlink_target_untouched(self):
        original = self.home/'external-i3'
        original.mkdir()
        (original/'keep').write_text('do not touch')
        (self.home/'.config').mkdir()
        (self.home/'.config/i3').symlink_to(original, target_is_directory=True)
        self.deploy()
        self.assertEqual((original/'keep').read_text(), 'do not touch')
        backups = list((self.home/'.local/state/masternaka-debian/backups').glob('*/i3'))
        self.assertTrue(backups[0].is_symlink())
        self.assertFalse((self.home/'.config/i3').is_symlink())

    def test_every_theme_applies_without_network_or_display(self):
        self.deploy()
        target = self.home/'.config/i3'
        for theme in (target/'themes').iterdir():
            with self.subTest(theme=theme.name):
                subprocess.run(['bash', str(target/'scripts/thememenu'), theme.name], env=self.env, check=True, capture_output=True)
                self.assertEqual((target/'current-theme').read_text().strip(), theme.name)
                self.assertEqual((target/'kitty/colors.conf').read_text(), (theme/'kitty.conf').read_text())
        result = subprocess.run(['bash', str(target/'scripts/thememenu'), '../../'], env=self.env, capture_output=True)
        self.assertNotEqual(result.returncode, 0)

    def test_invalid_argument_fails_without_writes(self):
        result = subprocess.run(['bash', str(ROOT/'install.sh'), '--unknown'], env=self.env, capture_output=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(list(self.home.iterdir()), [])

    def test_runtime_has_no_author_network_dependency(self):
        forbidden = ('justaguy.dev', 'codeberg.org', 'drewgrif', 'butterrepo', 'butterscripts', '+kitten themes')
        paths = [ROOT/'install.sh']
        for directory in ('i3', 'scripts', 'lib', 'packages'):
            paths.extend((ROOT/directory).rglob('*'))
        for path in paths:
            if path.is_file():
                for token in forbidden:
                    self.assertNotIn(token, path.read_text(), str(path))

if __name__ == '__main__':
    unittest.main()
