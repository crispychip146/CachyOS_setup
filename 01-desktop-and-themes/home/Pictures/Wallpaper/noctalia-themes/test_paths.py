"""Regression checks for recursive discovery and wallpaper hook selection."""
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import apply
import build


class WallpaperPaths(unittest.TestCase):
    def test_recursive_inventory_excludes_bundle_and_hidden_directories(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            for name in ('root.png', 'karina/nested/photo.JPG', '.hidden/secret.png',
                         'noctalia-themes/preview.png', 'karina/readme.txt'):
                path = root / name
                path.parent.mkdir(parents=True, exist_ok=True)
                path.touch()
            with patch.object(build, 'ROOT', root / 'noctalia-themes'):
                self.assertEqual(set(build.wallpaper_files()), {'root.png', 'karina/nested/photo.JPG'})
                manifest = {'wallpapers': {'root.png': {}}}
                (build.ROOT / 'manifest.json').write_text(json.dumps(manifest))
                self.assertEqual(build.list_new(), ['karina/nested/photo.JPG'])

    def test_moved_and_absent_curated_rows_are_retained(self):
        rows = [{'wallpaper': 'moved.png'}, {'wallpaper': 'absent.png'}]
        self.assertEqual(build.locate_rows(rows, {'karina/moved.png': Path('unused')}),
                         [{'wallpaper': 'karina/moved.png'}, {'wallpaper': 'absent.png'}])
        self.assertEqual(rows[0]['wallpaper'], 'moved.png')
        with self.assertRaisesRegex(ValueError, 'Ambiguous'):
            build.locate_rows(rows, {'a/moved.png': None, 'b/moved.png': None})
        with self.assertRaisesRegex(ValueError, 'need curated entries'):
            build.locate_rows(rows, {'new.png': None})

    def test_hook_resolves_subfolders_and_refuses_ambiguous_basenames(self):
        entries = {key: {'path': '/wallpapers/' + key, 'palette': key} for key in
                   ('a/same.png', 'b/same.png', 'karina/unique image.png', 'root.png')}
        manifest = {'wallpapers': entries}
        for path, key in (
                ('/wallpapers/a/same.png', 'a/same.png'),
                ('./b/same.png', 'b/same.png'),
                ('/relocated/a/same.png', 'a/same.png'),
                ('file:///wallpapers/karina/unique%20image.png', 'karina/unique image.png'),
                ('/wallpapers/karina/../root.png', 'root.png'),
                ('unique image.png', 'karina/unique image.png'),
                ('/moved/root.png', 'root.png')):
            with self.subTest(path=path):
                self.assertEqual(apply.resolve(manifest, path), entries[key])
        self.assertIsNone(apply.resolve(manifest, 'same.png'))
        self.assertIsNone(apply.resolve(manifest, '/unknown/same.png'))
        self.assertIsNone(apply.resolve(manifest, '/unknown/new.png'))

    def test_wallpaper_hook_changes_palette_and_folder_icons(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            entry = {'path': '/wallpapers/karina/new.png', 'palette': 'Exotic-New', 'name': 'New'}
            (root / 'manifest.json').write_text(json.dumps({'wallpapers': {'karina/new.png': entry}}))
            with patch.object(apply, 'ROOT', root), patch.object(apply, 'ipc', return_value='custom Old') as ipc, \
                    patch.object(apply, 'apply_for_palette') as icons, \
                    patch.dict('os.environ', {'NOCTALIA_WALLPAPER_PATH': entry['path']}), \
                    patch('sys.argv', ['apply.py']):
                self.assertEqual(apply.main(), 0)
                ipc.assert_any_call('color-scheme-set', 'custom', 'Exotic-New')
                icons.assert_called_once_with(root, 'Exotic-New')
                ipc.reset_mock()
                ipc.return_value = 'custom Exotic-New'
                apply.main()
                ipc.assert_called_once_with('color-scheme-get')


if __name__ == '__main__':
    unittest.main()
