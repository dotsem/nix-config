package backup

import (
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"

	"env-catcher/internal/scanner"
)

// Action represents the disposition of a scanned file.
type Action string

const (
	ActionCopy          Action = "copied"
	ActionSkipIdentical Action = "skipped (identical)"
	ActionCollision     Action = "copied (collision disambiguated)"
)

// Result logs the outcome for a single processed file.
type Result struct {
	Source      string
	Destination string
	Action      Action
	Checksum    string
}

// Summary provides aggregate metrics from a backup run.
type Summary struct {
	Found   int
	Copied  int
	Skipped int
	Results []Result
}

// Options configures the backup engine.
type Options struct {
	BackupDir    string
	DryRun       bool
	PreserveTree bool
}

// Run copies scanned files to BackupDir with safe permissions and deduplication.
func Run(files []scanner.FoundFile, opts Options) (*Summary, error) {
	if opts.BackupDir == "" {
		return nil, fmt.Errorf("backup directory must not be empty")
	}

	cleanDest, err := filepath.Abs(filepath.Clean(opts.BackupDir))
	if err != nil {
		return nil, fmt.Errorf("resolve backup dir: %w", err)
	}

	if !opts.DryRun {
		if err := os.MkdirAll(cleanDest, 0700); err != nil {
			return nil, fmt.Errorf("create backup directory: %w", err)
		}
	}

	summary := &Summary{Found: len(files)}
	destUsed := make(map[string]string)

	for _, file := range files {
		srcHash, err := hashFile(file.AbsPath)
		if err != nil {
			return nil, fmt.Errorf("hash source %s: %w", file.AbsPath, err)
		}

		var targetPath string
		if opts.PreserveTree {
			targetPath = filepath.Clean(file.RelPath)
		} else {
			targetPath = GenerateBackupName(file.RelPath)
		}

		destPath, action, err := resolveDestination(cleanDest, targetPath, srcHash, destUsed)
		if err != nil {
			return nil, err
		}

		if action == ActionSkipIdentical {
			summary.Skipped++
			summary.Results = append(summary.Results, Result{
				Source:      file.AbsPath,
				Destination: destPath,
				Action:      action,
				Checksum:    srcHash,
			})
			continue
		}

		if !opts.DryRun {
			if err := os.MkdirAll(filepath.Dir(destPath), 0700); err != nil {
				return nil, fmt.Errorf("create parent directory for %s: %w", destPath, err)
			}
			if err := copyFileSecure(file.AbsPath, destPath); err != nil {
				return nil, fmt.Errorf("copy %s to %s: %w", file.AbsPath, destPath, err)
			}
		}

		destUsed[destPath] = srcHash
		summary.Copied++
		summary.Results = append(summary.Results, Result{
			Source:      file.AbsPath,
			Destination: destPath,
			Action:      action,
			Checksum:    srcHash,
		})
	}

	return summary, nil
}

// GenerateBackupName flattens relative directories into snake_case prefixes.
func GenerateBackupName(relPath string) string {
	clean := filepath.Clean(relPath)
	dir := filepath.Dir(clean)
	base := filepath.Base(clean)

	if dir == "." {
		return base
	}

	slug := strings.ReplaceAll(filepath.ToSlash(dir), "/", "_")
	if base == ".env" {
		return slug + ".env"
	}
	if strings.HasPrefix(base, ".") {
		return slug + base
	}
	return slug + "_" + base
}

func resolveDestination(backupDir, targetPath, srcHash string, destUsed map[string]string) (string, Action, error) {
	destPath := filepath.Join(backupDir, targetPath)

	if matchExisting(destPath, srcHash, destUsed) {
		return destPath, ActionSkipIdentical, nil
	}

	if !fileExists(destPath) && destUsed[destPath] == "" {
		return destPath, ActionCopy, nil
	}

	dir := filepath.Dir(targetPath)
	file := filepath.Base(targetPath)
	ext := filepath.Ext(file)
	prefix := strings.TrimSuffix(file, ext)
	seq := 1

	for {
		candidate := filepath.Join(dir, fmt.Sprintf("%s_%d%s", prefix, seq, ext))
		candPath := filepath.Join(backupDir, candidate)

		if matchExisting(candPath, srcHash, destUsed) {
			return candPath, ActionSkipIdentical, nil
		}
		if !fileExists(candPath) && destUsed[candPath] == "" {
			return candPath, ActionCollision, nil
		}
		seq++
	}
}

func matchExisting(path, srcHash string, destUsed map[string]string) bool {
	if priorHash, ok := destUsed[path]; ok && priorHash == srcHash {
		return true
	}
	if fileExists(path) {
		existingHash, err := hashFile(path)
		if err == nil && existingHash == srcHash {
			return true
		}
	}
	return false
}

func copyFileSecure(src, dst string) (err error) {
	in, err := os.Open(src)
	if err != nil {
		return err
	}
	defer func() {
		if cErr := in.Close(); err == nil {
			err = cErr
		}
	}()

	out, err := os.OpenFile(dst, os.O_WRONLY|os.O_CREATE|os.O_TRUNC, 0600)
	if err != nil {
		return err
	}
	defer func() {
		if cErr := out.Close(); err == nil {
			err = cErr
		}
	}()

	if _, err = io.Copy(out, in); err != nil {
		return err
	}
	return out.Sync()
}

func hashFile(path string) (string, error) {
	f, err := os.Open(path)
	if err != nil {
		return "", err
	}
	defer func() {
		_ = f.Close()
	}()

	h := sha256.New()
	if _, err := io.Copy(h, f); err != nil {
		return "", err
	}
	return hex.EncodeToString(h.Sum(nil)), nil
}

func fileExists(path string) bool {
	info, err := os.Stat(path)
	return err == nil && !info.IsDir()
}
