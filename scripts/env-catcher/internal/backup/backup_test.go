package backup_test

import (
	"archive/tar"
	"compress/gzip"
	"io"
	"os"
	"path/filepath"
	"testing"

	"env-catcher/internal/backup"
	"env-catcher/internal/scanner"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestGenerateBackupName(t *testing.T) {
	tests := []struct {
		relPath  string
		expected string
	}{
		{relPath: ".env", expected: ".env"},
		{relPath: ".env.local", expected: ".env.local"},
		{relPath: "api/.env", expected: "api.env"},
		{relPath: "web/client/.env.local", expected: "web_client.env.local"},
		{relPath: "services/auth/db.env", expected: "services_auth_db.env"},
	}

	for _, tc := range tests {
		t.Run(tc.relPath, func(t *testing.T) {
			actual := backup.GenerateBackupName(tc.relPath)
			assert.Equal(t, tc.expected, actual)
		})
	}
}

func TestRun(t *testing.T) {
	t.Run("copies files with 0600 permissions", func(t *testing.T) {
		tmp := t.TempDir()
		srcDir := filepath.Join(tmp, "src")
		dstDir := filepath.Join(tmp, "dst")

		srcFile := filepath.Join(srcDir, "app", ".env")
		createTestFile(t, srcFile, "SECRET_TOKEN=xyz")

		found := []scanner.FoundFile{
			{AbsPath: srcFile, RelPath: "app/.env", Size: int64(len("SECRET_TOKEN=xyz"))},
		}

		summary, err := backup.Run(found, backup.Options{
			BackupDir: dstDir,
			DryRun:    false,
		})
		require.NoError(t, err)
		assert.Equal(t, 1, summary.Found)
		assert.Equal(t, 1, summary.Copied)
		assert.Equal(t, 0, summary.Skipped)

		targetFile := filepath.Join(dstDir, "app.env")
		info, err := os.Stat(targetFile)
		require.NoError(t, err)
		assert.Equal(t, os.FileMode(0600), info.Mode().Perm())

		content, err := os.ReadFile(targetFile)
		require.NoError(t, err)
		assert.Equal(t, "SECRET_TOKEN=xyz", string(content))
	})

	t.Run("skips identical files with same content", func(t *testing.T) {
		tmp := t.TempDir()
		dstDir := filepath.Join(tmp, "dst")

		file1 := filepath.Join(tmp, "a", ".env")
		createTestFile(t, file1, "COMMON=1")

		found := []scanner.FoundFile{
			{AbsPath: file1, RelPath: "a/.env", Size: int64(len("COMMON=1"))},
		}

		// First copy
		_, err := backup.Run(found, backup.Options{BackupDir: dstDir})
		require.NoError(t, err)

		// Second copy of identical file to same destination
		summary2, err := backup.Run(found, backup.Options{BackupDir: dstDir})
		require.NoError(t, err)
		assert.Equal(t, 0, summary2.Copied)
		assert.Equal(t, 1, summary2.Skipped)
	})

	t.Run("disambiguates collision when contents differ", func(t *testing.T) {
		tmp := t.TempDir()
		dstDir := filepath.Join(tmp, "dst")

		// Both map to app_service.env
		file1 := filepath.Join(tmp, "app", "service", ".env")
		file2 := filepath.Join(tmp, "app_service", ".env")
		createTestFile(t, file1, "VAL=ONE")
		createTestFile(t, file2, "VAL=TWO")

		found := []scanner.FoundFile{
			{AbsPath: file1, RelPath: "app/service/.env", Size: int64(len("VAL=ONE"))},
			{AbsPath: file2, RelPath: "app_service/.env", Size: int64(len("VAL=TWO"))},
		}

		summary, err := backup.Run(found, backup.Options{BackupDir: dstDir})
		require.NoError(t, err)
		assert.Equal(t, 2, summary.Copied)

		content1, err := os.ReadFile(filepath.Join(dstDir, "app_service.env"))
		require.NoError(t, err)
		assert.Equal(t, "VAL=ONE", string(content1))

		content2, err := os.ReadFile(filepath.Join(dstDir, "app_service_1.env"))
		require.NoError(t, err)
		assert.Equal(t, "VAL=TWO", string(content2))
	})

	t.Run("dry run performs no filesystem mutations", func(t *testing.T) {
		tmp := t.TempDir()
		dstDir := filepath.Join(tmp, "dst")
		srcFile := filepath.Join(tmp, "service", ".env")
		createTestFile(t, srcFile, "DRY=1")

		found := []scanner.FoundFile{
			{AbsPath: srcFile, RelPath: "service/.env", Size: int64(len("DRY=1"))},
		}

		summary, err := backup.Run(found, backup.Options{
			BackupDir: dstDir,
			DryRun:    true,
		})
		require.NoError(t, err)
		assert.Equal(t, 1, summary.Copied)
		assert.NoDirExists(t, dstDir)
	})
}

func TestCreateArchive(t *testing.T) {
	t.Run("generates valid tar.gz with 0600 modes", func(t *testing.T) {
		tmp := t.TempDir()
		archivePath := filepath.Join(tmp, "backup.tar.gz")

		srcFile := filepath.Join(tmp, "web", ".env")
		createTestFile(t, srcFile, "ARCHIVE=TRUE")

		found := []scanner.FoundFile{
			{AbsPath: srcFile, RelPath: "web/.env", Size: int64(len("ARCHIVE=TRUE"))},
		}

		summary, err := backup.CreateArchive(found, backup.ArchiveOptions{
			ArchivePath: archivePath,
			DryRun:      false,
		})
		require.NoError(t, err)
		assert.Equal(t, 1, summary.Copied)

		info, err := os.Stat(archivePath)
		require.NoError(t, err)
		assert.Equal(t, os.FileMode(0600), info.Mode().Perm())

		f, err := os.Open(archivePath)
		require.NoError(t, err)
		defer func() {
			_ = f.Close()
		}()

		gz, err := gzip.NewReader(f)
		require.NoError(t, err)
		defer func() {
			_ = gz.Close()
		}()

		tr := tar.NewReader(gz)
		hdr, err := tr.Next()
		require.NoError(t, err)
		assert.Equal(t, "web.env", hdr.Name)
		assert.Equal(t, int64(0600), hdr.Mode)

		content, err := io.ReadAll(tr)
		require.NoError(t, err)
		assert.Equal(t, "ARCHIVE=TRUE", string(content))
	})
}

func createTestFile(t *testing.T, path, content string) {
	t.Helper()
	err := os.MkdirAll(filepath.Dir(path), 0755)
	require.NoError(t, err)
	err = os.WriteFile(path, []byte(content), 0600)
	require.NoError(t, err)
}
