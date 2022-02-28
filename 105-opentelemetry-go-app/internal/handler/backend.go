// Aternity Tech-Community
// 105-opentelemetry-go-app

package handler

import (
	"fmt"
	"go.opentelemetry.io/otel"
	"log"
	"net/http"
	appconfig "opentelemetry-go-example/internal/config"
	"time"
)

func BackendHandler() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		log.Println("Received backend request to:", r.Host, r.URL.Path, "::", r.Method)

		// Common sleep time
		duration := time.Duration(appconfig.Sleep) * time.Millisecond

		// Make spans look pretty
		time.Sleep(duration)

		// Now start a child span
		_, span := otel.Tracer("otel-go-backend").Start(r.Context(), "backend-work")

		time.Sleep(duration)
		span.AddEvent("backend-job")

		w.WriteHeader(http.StatusOK)
		responseBody := fmt.Sprintf("From backend: %s", time.Now().Local().Format("15:04:05.000"))
		_, _ = w.Write([]byte(responseBody))

		time.Sleep(duration)
		span.End()
		time.Sleep(duration)
	}
}
