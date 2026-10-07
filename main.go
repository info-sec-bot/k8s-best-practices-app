package main

import (
	"log"
	"net/http"
	"os"
	"path/filepath"
)

func main() {
	publicDir := "./public"

	// API Route
	http.HandleFunc("/api/health", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.Write([]byte(`{"status": "healthy", "engine": "go"}`))
	})

	// Static Web Assets Route (SPA friendly)
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		path := filepath.Join(publicDir, r.URL.Path)
		if _, err := os.Stat(path); os.IsNotExist(err) {
			http.ServeFile(w, r, filepath.Join(publicDir, "index.html"))
			return
		}
		http.FileServer(http.Dir(publicDir)).ServeHTTP(w, r)
	})

	log.Println("Production server listening on port 8080...")
	log.Fatal(http.ListenAndServe(":8080", nil))
}

