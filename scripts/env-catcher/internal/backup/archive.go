package backup

import (
	"archive/tar"
	"compress/gzip"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"

	"env-catcher/internal/scanner"
)

// ArchiveOptions configures compressed tar.gz backup archiving.
type ArchiveOptions struct {
	ArchivePath string
	DryRun      bool
}

// CreateArchive streams scanned files into a tar.gz bundle with 0600 file modes.
func CreateArchive(files []scanner.FoundFile, opts ArchiveOptions) (summary *Summary, err error) {
	if opts.ArchivePath == "" {
		return nil, fmt.Errorf("archive path must not be empty")
	}

	cleanArchive, err := filepath.Abs(filepath.Clean(opts.ArchivePath))
	if err != nil {
		return nil, fmt.Errorf("resolve archive path: %w", err)
	}

	summary = &Summary{Found: len(files)}
	destUsed := make(map[string]string)

	var tw *tar.Writer
	var gw *gzip.Writer
	var outFile *os.File

	if !opts.DryRun {
		if err = os.MkdirAll(filepath.Dir(cleanArchive), 0700); err != nil {
			return nil, fmt.Errorf("create archive directory: %w", err)
		}

		outFile, err = os.OpenFile(cleanArchive, os.O_WRONLY|os.O_CREATE|os.O_TRUNC, 0600)
		if err != nil {
			return nil, fmt.Errorf("open archive file: %w", err)
		}
		defer func() {
			if cErr := outFile.Close(); err == nil {
				err = cErr
			}
		}()

		gw = gzip.NewWriter(outFile)
		defer func() {
			if cErr := gw.Close(); err == nil {
				err = cErr
			}
		}()

		tw = tar.NewWriter(gw)
		defer func() {
			if cErr := tw.Close(); err == nil {
				err = cErr
			}
		}()
	}

	for _, file := range files {
		srcHash, hashErr := hashFile(file.AbsPath)
		if hashErr != nil {
			return nil, fmt.Errorf("hash source %s: %w", file.AbsPath, hashErr)
		}

		baseName := GenerateBackupName(file.RelPath)
		entryName, action := resolveArchiveEntry(baseName, srcHash, destUsed)

		if action == ActionSkipIdentical {
			summary.Skipped++
			summary.Results = append(summary.Results, Result{
				Source:      file.AbsPath,
				Destination: entryName,
				Action:      action,
				Checksum:    srcHash,
			})
			continue
		}

		if !opts.DryRun {
			if wErr := writeTarEntry(tw, file.AbsPath, entryName, file.Size); wErr != nil {
				return nil, fmt.Errorf("write archive entry for %s: %w", file.AbsPath, wErr)
			}
		}

		destUsed[entryName] = srcHash
		summary.Copied++
		summary.Results = append(summary.Results, Result{
			Source:      file.AbsPath,
			Destination: entryName,
			Action:      action,
			Checksum:    srcHash,
		})
	}

	return summary, nil
}

func resolveArchiveEntry(baseName, srcHash string, destUsed map[string]string) (string, Action) {
	if priorHash, exists := destUsed[baseName]; exists {
		if priorHash == srcHash {
			return baseName, ActionSkipIdentical
		}

		ext := filepath.Ext(baseName)
		prefix := strings.TrimSuffix(baseName, ext)
		seq := 1
		for {
			candidate := fmt.Sprintf("%s_%d%s", prefix, seq, ext)
			candHash, candExists := destUsed[candidate]
			if candExists && candHash == srcHash {
				return candidate, ActionSkipIdentical
			}
			if !candExists {
				return candidate, ActionCollision
			}
			seq++
		}
	}

	return baseName, ActionCopy
}

func writeTarEntry(tw *tar.Writer, srcPath, entryName string, size int64) error {
	f, err := os.Open(srcPath)
	if err != nil {
		return err
	}
	defer func() {
		_ = f.Close()
	}()

	header := &tar.Header{
		Name:     entryName,
		Mode:     0600,
		Size:     size,
		Typeflag: tar.TypeReg,
	}

	if err := tw.WriteHeader(header); err != nil {
		return err
	}

	_, err = io.Copy(tw, f)
	return err
}
