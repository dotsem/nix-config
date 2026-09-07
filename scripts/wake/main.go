package main

import (
	"errors"
	"log/slog"
	"net/http"
	"os"
	"os/exec"
)

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

	slog.Info("Server started on :9099", slog.String("mac", mac), slog.String("subnet", subnet))
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
