package scanner_test

import (
	"os"
	"os/exec"
	"path/filepath"
	"testing"

	"env-catcher/internal/scanner"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestScan(t *testing.T) {
	t.Run("returns error when root does not exist", func(t *testing.T) {
		_, err := scanner.Scan(scanner.Options{
			ScanDir: filepath.Join(t.TempDir(), "nonexistent"),
		})
		assert.Error(t, err)
	})

	t.Run("returns error when root is a file", func(t *testing.T) {
		tmp := t.TempDir()
		filePath := filepath.Join(tmp, "somefile.txt")
		err := os.WriteFile(filePath, []byte("hello"), 0600)
		require.NoError(t, err)

		_, err = scanner.Scan(scanner.Options{
			ScanDir: filePath,
		})
		assert.Error(t, err)
	})

	t.Run("discovers env files and prunes ignored directories", func(t *testing.T) {
		tmp := t.TempDir()

		// Structure:
		// tmp/.env
		// tmp/app/.env.local
		// tmp/vendor/secret.env
		// tmp/.env.template (pruned)
		// tmp/node_modules/test/.env (pruned)
		// tmp/.git/.env (pruned)
		createTestFile(t, filepath.Join(tmp, ".env"), "ROOT=1")
		createTestFile(t, filepath.Join(tmp, "app", ".env.local"), "LOCAL=1")
		createTestFile(t, filepath.Join(tmp, "vendor", "secret.env"), "VENDOR=1")
		createTestFile(t, filepath.Join(tmp, ".env.template"), "IGNORED=1")
		createTestFile(t, filepath.Join(tmp, "node_modules", "test", ".env"), "IGNORED=1")
		createTestFile(t, filepath.Join(tmp, ".git", ".env"), "IGNORED=1")

		files, err := scanner.Scan(scanner.Options{
			ScanDir: tmp,
		})
		require.NoError(t, err)
		assert.Len(t, files, 3)

		relPaths := make([]string, len(files))
		for i, f := range files {
			relPaths[i] = f.RelPath
		}

		assert.Contains(t, relPaths, ".env")
		assert.Contains(t, relPaths, filepath.Join("app", ".env.local"))
		assert.Contains(t, relPaths, filepath.Join("vendor", "secret.env"))

		assert.NotContains(t, relPaths, ".env.template")
		assert.NotContains(t, relPaths, filepath.Join("node_modules", "test", ".env"))
		assert.NotContains(t, relPaths, filepath.Join(".git", ".env"))
	})

	t.Run("prunes editor, toolchain, and trash directories", func(t *testing.T) {
		tmp := t.TempDir()
		createTestFile(t, filepath.Join(tmp, "valid", ".env"), "VALID=1")
		createTestFile(t, filepath.Join(tmp, "History", ".env"), "PRUNED=1")
		createTestFile(t, filepath.Join(tmp, ".vscode", ".env"), "PRUNED=1")
		createTestFile(t, filepath.Join(tmp, ".cargo", ".env"), "PRUNED=1")
		createTestFile(t, filepath.Join(tmp, "pkg", "mod", ".env"), "PRUNED=1")
		createTestFile(t, filepath.Join(tmp, "ephemeral", ".env"), "PRUNED=1")
		createTestFile(t, filepath.Join(tmp, ".dart_tool", ".env"), "PRUNED=1")
		createTestFile(t, filepath.Join(tmp, "Trash", ".env"), "PRUNED=1")

		// Excluded patterns
		createTestFile(t, filepath.Join(tmp, "valid", ".env.trashinfo"), "EXCLUDED=1")
		createTestFile(t, filepath.Join(tmp, "valid", ".env.test.prod"), "EXCLUDED=1")
		createTestFile(t, filepath.Join(tmp, "valid", "app.test.env"), "EXCLUDED=1")

		files, err := scanner.Scan(scanner.Options{
			ScanDir: tmp,
		})
		require.NoError(t, err)
		assert.Len(t, files, 1)
		assert.Equal(t, filepath.Join("valid", ".env"), files[0].RelPath)
	})

	t.Run("skips git tracked files when SkipGitTracked is true", func(t *testing.T) {
		tmp := t.TempDir()

		// Set up a git repo in tmp
		runGit(t, tmp, "init")
		runGit(t, tmp, "config", "user.email", "test@test.local")
		runGit(t, tmp, "config", "user.name", "Test Runner")

		trackedFile := filepath.Join(tmp, "committed.env")
		untrackedFile := filepath.Join(tmp, "secret.env")
		createTestFile(t, trackedFile, "TRACKED=1")
		createTestFile(t, untrackedFile, "SECRET=1")

		runGit(t, tmp, "add", "committed.env")

		// With SkipGitTracked = true
		files, err := scanner.Scan(scanner.Options{
			ScanDir:        tmp,
			SkipGitTracked: true,
		})
		require.NoError(t, err)
		assert.Len(t, files, 1)
		assert.Equal(t, "secret.env", files[0].RelPath)

		// With SkipGitTracked = false
		allFiles, err := scanner.Scan(scanner.Options{
			ScanDir:        tmp,
			SkipGitTracked: false,
		})
		require.NoError(t, err)
		assert.Len(t, allFiles, 2)
	})

	t.Run("respects custom prune directories", func(t *testing.T) {
		tmp := t.TempDir()
		createTestFile(t, filepath.Join(tmp, "custom_skip", ".env"), "SKIP=1")
		createTestFile(t, filepath.Join(tmp, "valid", ".env"), "KEEP=1")

		files, err := scanner.Scan(scanner.Options{
			ScanDir:   tmp,
			PruneDirs: []string{"custom_skip"},
		})
		require.NoError(t, err)
		assert.Len(t, files, 1)
		assert.Equal(t, filepath.Join("valid", ".env"), files[0].RelPath)
	})
}

func runGit(t *testing.T, dir string, args ...string) {
	t.Helper()
	cmd := exec.Command("git", append([]string{"-C", dir}, args...)...)
	out, err := cmd.CombinedOutput()
	require.NoError(t, err, "git error: %s", string(out))
}

func createTestFile(t *testing.T, path, content string) {
	t.Helper()
	err := os.MkdirAll(filepath.Dir(path), 0755)
	require.NoError(t, err)
	err = os.WriteFile(path, []byte(content), 0600)
	require.NoError(t, err)
}
