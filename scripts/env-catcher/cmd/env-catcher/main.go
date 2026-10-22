package main

import (
	"errors"
	"flag"
	"fmt"
	"os"
	"strings"

	"env-catcher/internal/backup"
	"env-catcher/internal/scanner"
)

func main() {
	if err := run(os.Args[1:]); err != nil {
		fmt.Fprintf(os.Stderr, "error: %v\n", err)
		os.Exit(1)
	}
}

func run(args []string) error {
	fs := flag.NewFlagSet("env-catcher", flag.ContinueOnError)

	var (
		scanDir        string
		destDir        string
		archiveFile    string
		dryRun         bool
		patternsRaw    string
		excludeRaw     string
		pruneRaw       string
		skipGitTracked bool
		preserveTree   bool
	)

	fs.StringVar(&scanDir, "scan", "", "Directory to scan for .env files")
	fs.StringVar(&destDir, "dest", "", "Destination directory for backups")
	fs.StringVar(&archiveFile, "archive", "", "Path to output .tar.gz bundle (overrides -dest)")
	fs.BoolVar(&dryRun, "dry-run", false, "Preview actions without writing files")
	fs.BoolVar(&skipGitTracked, "skip-git-tracked", true, "Skip .env files that are already tracked by git")
	fs.BoolVar(&preserveTree, "preserve-tree", false, "Preserve relative directory structure instead of flattening filenames")
	fs.StringVar(&patternsRaw, "patterns", "", "Comma-separated glob patterns (default: .env,.env.*,*.env)")
	fs.StringVar(&excludeRaw, "exclude", "", "Additional comma-separated patterns to exclude")
	fs.StringVar(&pruneRaw, "prune", "", "Additional comma-separated directory names to prune")

	fs.Usage = func() {
		out := fs.Output()
		_, _ = fmt.Fprintf(out, "Usage: env-catcher [options] <scan_directory> [destination_directory]\n\n")
		_, _ = fmt.Fprintf(out, "Recursively finds and backs up .env files with safe 0600 permissions.\n\n")
		_, _ = fmt.Fprintf(out, "Options:\n")
		fs.PrintDefaults()
	}

	if err := fs.Parse(args); err != nil {
		if errors.Is(err, flag.ErrHelp) {
			return nil
		}
		return err
	}

	// Fallback to positional arguments if flags weren't supplied
	rest := fs.Args()
	if scanDir == "" && len(rest) > 0 {
		scanDir = rest[0]
	}
	if destDir == "" && archiveFile == "" && len(rest) > 1 {
		destDir = rest[1]
	}

	if scanDir == "" {
		fs.Usage()
		return fmt.Errorf("scan directory is required")
	}
	if destDir == "" && archiveFile == "" {
		fs.Usage()
		return fmt.Errorf("destination directory (-dest) or archive path (-archive) is required")
	}

	patterns := splitCommaList(patternsRaw)
	extraExcludes := splitCommaList(excludeRaw)
	extraPrune := splitCommaList(pruneRaw)

	fmt.Printf("Scanning: %s\n", scanDir)
	found, err := scanner.Scan(scanner.Options{
		ScanDir:        scanDir,
		Patterns:       patterns,
		Excludes:       append(scanner.DefaultExcludePatterns, extraExcludes...),
		PruneDirs:      extraPrune,
		SkipGitTracked: skipGitTracked,
	})
	if err != nil {
		return fmt.Errorf("scan failed: %w", err)
	}

	if len(found) == 0 {
		fmt.Println("No environment files found.")
		return nil
	}

	fmt.Printf("Found %d file(s):\n", len(found))
	for _, f := range found {
		fmt.Printf("  • %s\n", f.RelPath)
	}
	fmt.Println()

	var summary *backup.Summary
	if archiveFile != "" {
		fmt.Printf("Target archive: %s\n", archiveFile)
		summary, err = backup.CreateArchive(found, backup.ArchiveOptions{
			ArchivePath:  archiveFile,
			DryRun:       dryRun,
			PreserveTree: preserveTree,
		})
	} else {
		fmt.Printf("Target directory: %s\n", destDir)
		summary, err = backup.Run(found, backup.Options{
			BackupDir:    destDir,
			DryRun:       dryRun,
			PreserveTree: preserveTree,
		})
	}
	if err != nil {
		return fmt.Errorf("backup failed: %w", err)
	}

	printSummary(summary, dryRun)
	return nil
}

func printSummary(s *backup.Summary, dryRun bool) {
	prefix := ""
	if dryRun {
		prefix = "[DRY-RUN] "
	}

	fmt.Println()
	for _, r := range s.Results {
		fmt.Printf("%s%s -> %s [%s]\n", prefix, r.Source, r.Destination, r.Action)
	}

	fmt.Println()
	fmt.Printf("%sSummary:\n", prefix)
	fmt.Printf("  Found:   %d\n", s.Found)
	fmt.Printf("  Copied:  %d\n", s.Copied)
	fmt.Printf("  Skipped: %d\n", s.Skipped)
}

func splitCommaList(val string) []string {
	if strings.TrimSpace(val) == "" {
		return nil
	}
	parts := strings.Split(val, ",")
	var res []string
	for _, p := range parts {
		trimmed := strings.TrimSpace(p)
		if trimmed != "" {
			res = append(res, trimmed)
		}
	}
	return res
}
