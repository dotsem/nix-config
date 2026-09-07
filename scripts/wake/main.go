package main

import (
	"errors"
	"fmt"
	"log/slog"
	"net/http"
	"os"
	"os/exec"
)

var targetIP string

func main() {
	mac := os.Getenv("WAKE_MAC")
	subnet := os.Getenv("WAKE_SUBNET")

	if mac == "" || subnet == "" {
		slog.Error("WAKE_MAC or WAKE_SUBNET not set")
		os.Exit(1)
	}

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path != "/" && r.URL.Path != "/wake" {
			http.NotFound(w, r)
			return
		}
		wake(w, r, mac, subnet)
	})

	http.HandleFunc("/status", func(w http.ResponseWriter, r *http.Request) {
		status(w, r, targetIP)
	})

	slog.Info("Server started on :9099", slog.String("mac", mac), slog.String("subnet", subnet), slog.String("targetIP", targetIP))
	if err := http.ListenAndServe(":9099", nil); err != nil && !errors.Is(err, http.ErrServerClosed) {
		slog.Error("Server stopped unexpectedly", slog.Any("error", err))
		os.Exit(1)
	}
}

func wake(w http.ResponseWriter, r *http.Request, mac, subnet string) {
	err := exec.Command("wakeonlan", "-i", subnet, mac).Run()
	if err != nil {
		slog.Error("Failed to wake machine", slog.Any("error", err))
		http.Error(w, "Failed to wake machine", http.StatusInternalServerError)
		return
	}

	slog.Info("Wake packet sent", slog.String("mac", mac), slog.String("subnet", subnet))
	http.Redirect(w, r, "/", http.StatusFound)
}

func status(w http.ResponseWriter, r *http.Request, targetIP string) {
	out, err := exec.Command("ping", "-c", "1", "-W", "1", targetIP).CombinedOutput()
	if err != nil {
		slog.Error("Ping failed", slog.String("target", targetIP), slog.String("output", string(out)), slog.Any("error", err))
		http.Error(w, fmt.Sprintf("Ping failed for %q: %v\nOutput: %s", targetIP, err, string(out)), http.StatusServiceUnavailable)
		return
	}
	w.WriteHeader(http.StatusOK)
	_, _ = w.Write([]byte("OK"))
}
