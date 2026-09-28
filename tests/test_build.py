"""Tests de gestion des versions ; téléchargements et compilateurs simulés."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
HARNESS = r'''
source "$1/scripts/build-desktop.sh"
shift
build_preflight() { :; }
build_require_tools() { :; }
flock() { :; }
# Équivalent de mv -Tf pour tester les liens sur macOS aussi.
mv() { python3 -c 'import os,sys; os.replace(sys.argv[1], sys.argv[2])' "$2" "$3"; }
fake_build() {
    printf '%s\n' "$1" >> "$HOME/build.log"
    if [[ ${TEST_FAIL:-} == "$1" ]]; then return 1; fi
    mkdir -p "$2/bin"
    printf '#!/bin/sh\nexit 0\n' > "$2/bin/$1"
    chmod +x "$2/bin/$1"
}
build_picom() { fake_build picom "$1"; }
build_rofi() { fake_build rofi "$1"; }
build_main "$@"
'''


class BuildTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.home = Path(self.tmp.name).resolve() / 'user with spaces'
        self.home.mkdir()
        self.env = {**os.environ, 'HOME': str(self.home)}
        self.base = self.home / '.local/share/masternaka-debian'

    def run_build(self, *args, fail='', check=True):
        return subprocess.run(
            ['bash', '-c', HARNESS, 'test', str(ROOT), *args],
            env={**self.env, 'TEST_FAIL': fail}, check=check,
            capture_output=True, text=True,
        )

    def builds(self):
        log = self.home / 'build.log'
        return log.read_text().splitlines() if log.exists() else []

    def test_repeat_reuses_both_without_new_release(self):
        self.run_build()
        first = (self.base / 'current').resolve()
        self.run_build()
        self.assertEqual(self.builds(), ['picom', 'rofi'])
        self.assertEqual((self.base / 'current').resolve(), first)
        self.assertEqual(len(list((self.base / 'releases').iterdir())), 1)
        self.assertEqual(list(self.base.glob('.build.*')), [self.base / '.build.lock'])

    def test_selected_force_preserves_other_and_rollback_swaps(self):
        self.run_build()
        first = (self.base / 'current').resolve()
        original_picom = (first / 'bin/picom').resolve()
        self.run_build('rofi', '--force')
        second = (self.base / 'current').resolve()
        self.assertNotEqual(first, second)
        self.assertEqual((second / 'bin/picom').resolve(), original_picom)
        self.assertEqual(self.builds(), ['picom', 'rofi', 'rofi'])
        self.run_build('--rollback')
        self.assertEqual((self.base / 'current').resolve(), first)
        self.run_build('--rollback')
        self.assertEqual((self.base / 'current').resolve(), second)
        self.assertEqual(self.builds(), ['picom', 'rofi', 'rofi'])

    def test_failure_keeps_active_release_and_cleans_partial_build(self):
        self.run_build()
        first = (self.base / 'current').resolve()
        result = self.run_build('--force', fail='rofi', check=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual((self.base / 'current').resolve(), first)
        self.assertEqual(list((self.base / 'releases').iterdir()), [first])
        self.assertEqual(list(self.base.glob('.build.*')), [self.base / '.build.lock'])

    def test_changed_reference_rebuilds_only_affected_component(self):
        self.run_build()
        (self.base / 'current/picom/source-id').write_text('older commit\n')
        self.run_build()
        self.assertEqual(self.builds(), ['picom', 'rofi', 'picom'])

    def test_broken_binary_is_rebuilt(self):
        self.run_build()
        binary = (self.base / 'current/bin/rofi').resolve()
        binary.write_text('#!/bin/sh\nexit 1\n')
        self.run_build()
        self.assertEqual(self.builds(), ['picom', 'rofi', 'rofi'])

    def test_selecting_one_before_initial_install_fails(self):
        result = self.run_build('picom', check=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse((self.base / 'current').exists())
        self.assertEqual(self.builds(), [])

    def test_legacy_install_is_preserved_during_migration(self):
        old = self.base / 'releases/legacy'
        (old / 'bin').mkdir(parents=True)
        for name in ('picom', 'rofi'):
            binary = old / 'bin' / name
            binary.write_text('#!/bin/sh\nexit 0\n')
            binary.chmod(0o755)
        (self.base / 'current').symlink_to(old)
        self.run_build('picom')
        self.assertEqual(self.builds(), ['picom'])
        self.assertEqual((self.base / 'current/bin/rofi').resolve(), old / 'bin/rofi')
        self.assertEqual((self.base / 'previous').resolve(), old)
        self.run_build()
        self.assertEqual(self.builds(), ['picom', 'rofi'])

    def test_invalid_options_and_help_do_not_write(self):
        for args in (['--unknown'], ['--rollback', '--force'], ['picom', 'rofi']):
            result = self.run_build(*args, check=False)
            self.assertNotEqual(result.returncode, 0)
        self.run_build('--help')
        self.assertEqual(list(self.home.iterdir()), [])

    def test_missing_rollback_does_not_build(self):
        self.run_build()
        first = (self.base / 'current').resolve()
        result = self.run_build('--rollback', check=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual((self.base / 'current').resolve(), first)
        self.assertEqual(self.builds(), ['picom', 'rofi'])


if __name__ == '__main__':
    unittest.main()
