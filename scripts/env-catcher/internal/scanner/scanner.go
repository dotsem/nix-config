package scanner

import (
	"fmt"
	"io/fs"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

// DefaultPruneDirs lists directories pruned during traversal to prevent noise.
var DefaultPruneDirs = []string{
	".git",
	"node_modules",
	".direnv",
	"target",
	"dist",
	".cache",
	"build",
	".venv",
	"History",
	".vscode",
	".vscode-server",
	".cargo",
	".rustup",
	".pub-cache",
	".npm",
	"pkg",
	"ephemeral",
	".dart_tool",
	"Pods",
	"DerivedData",
	"Trash",
	".Trash",
}

// DefaultExcludePatterns lists template, test, and non-env garbage file patterns to ignore.
var DefaultExcludePatterns = []string{
	"*.template",
	"*.example",
	"*.sample",
	"*.dist",
	"*.default",
	"*.trashinfo",
	"*.bak",
	"*.swp",
	"*.tmp",
	"*.test.*",
	"*.test.env",
	"*.spec.env",
}

// FoundFile describes an environment file discovered during scanning.
type FoundFile struct {
	AbsPath string
	RelPath string
	Size    int64
}

// Options configures the directory scan behavior.
type Options struct {
	ScanDir        string
	Patterns       []string
	Excludes       []string
	PruneDirs      []string
	SkipGitTracked bool
}

// Scan traverses ScanDir, pruning ignored directories and returning matched env files.
func Scan(opts Options) ([]FoundFile, error) {
	if opts.ScanDir == "" {
		return nil, fmt.Errorf("scan directory must not be empty")
	}

	cleanRoot, err := filepath.Abs(filepath.Clean(opts.ScanDir))
	if err != nil {
		return nil, fmt.Errorf("resolve scan dir: %w", err)
	}

	info, err := os.Stat(cleanRoot)
	if err != nil {
		return nil, fmt.Errorf("stat scan dir: %w", err)
	}
	if !info.IsDir() {
		return nil, fmt.Errorf("scan path is not a directory: %s", cleanRoot)
	}

	pruneMap := makePruneMap(opts.PruneDirs)
	patterns := opts.Patterns
	if len(patterns) == 0 {
		patterns = []string{".env", ".env.*", "*.env"}
	}
	excludes := opts.Excludes
	if len(excludes) == 0 {
		excludes = DefaultExcludePatterns
	}

	var results []FoundFile
	walkFn := func(path string, d fs.DirEntry, walkErr error) error {
		if walkErr != nil {
			return walkErr
		}

		name := d.Name()
		if d.IsDir() {
			if path != cleanRoot && pruneMap[name] {
				return filepath.SkipDir
			}
			return nil
		}

		if matchesAny(name, excludes) {
			return nil
		}

		if !matchesAny(name, patterns) {
			return nil
		}

		if opts.SkipGitTracked && isGitTracked(path) {
			return nil
		}

		relPath, relErr := filepath.Rel(cleanRoot, path)
		if relErr != nil {
			return fmt.Errorf("calculate relative path: %w", relErr)
		}

		fileInfo, infoErr := d.Info()
		if infoErr != nil {
			return fmt.Errorf("get file info for %s: %w", path, infoErr)
		}

		results = append(results, FoundFile{
			AbsPath: path,
			RelPath: relPath,
			Size:    fileInfo.Size(),
		})
		return nil
	}

	if err := filepath.WalkDir(cleanRoot, walkFn); err != nil {
		return nil, fmt.Errorf("walk directory: %w", err)
	}

	return results, nil
}

func makePruneMap(custom []string) map[string]bool {
	m := make(map[string]bool)
	for _, dir := range DefaultPruneDirs {
		m[dir] = true
	}
	for _, dir := range custom {
		trimmed := strings.TrimSpace(dir)
		if trimmed != "" {
			m[trimmed] = true
		}
	}
	return m
}

func matchesAny(filename string, patterns []string) bool {
	for _, pattern := range patterns {
		matched, err := filepath.Match(pattern, filename)
		if err == nil && matched {
			return true
		}
	}
	return false
}

func isGitTracked(absFilePath string) bool {
	dir := filepath.Dir(absFilePath)
	cmd := exec.Command("git", "-C", dir, "ls-files", "--error-unmatch", filepath.Base(absFilePath))
	return cmd.Run() == nil
}
