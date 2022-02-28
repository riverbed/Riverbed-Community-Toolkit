// Aternity Tech-Community
// 105-opentelemetry-go-app

package handler

import (
	"fmt"
	"go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp"
	"go.opentelemetry.io/otel"
	"io/ioutil"
	"log"
	"net/http"
	appconfig "opentelemetry-go-example/internal/config"
	"time"
)

func FrontendHandler() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		log.Println("Received frontend request to:", r.Host, r.URL.Path, "::", r.Method)

		// Common sleep time
		duration := time.Duration(appconfig.Sleep) * time.Millisecond

		// Make spans look pretty
		time.Sleep(duration)

		// Now start a child span
		_, span := otel.Tracer("otel-go-frontend").Start(r.Context(), "frontend-work")

		// Add an event
		time.Sleep(duration)
		span.AddEvent("frontend-job")

		time.Sleep(duration)

		// Make wrapped call to backend
		backendURL := fmt.Sprintf("http://%s:%s/", appconfig.Config["BACKEND_SERVER"],
			appconfig.Config["BACKEND_PORT"])
		backendResponse, err := otelhttp.Post(r.Context(), backendURL, "text/html", nil)
		if err != nil {
			log.Fatal("Bad backend request:", backendURL, ";", err)
		}

		backendBody := "Bad backend"
		if backendResponse.StatusCode == http.StatusOK {
			bodyBytes, err := ioutil.ReadAll(backendResponse.Body)
			if err != nil {
				log.Fatal(err)
			}
			backendBody = string(bodyBytes)
		}
		_ = backendResponse.Body.Close()

		time.Sleep(duration)

		w.WriteHeader(http.StatusOK)
		responseBody := fmt.Sprintf("From frontend: %s [%s]\n",
			time.Now().Local().Format("15:04:05.000"), backendBody)
		_, _ = w.Write([]byte(responseBody))

		span.End()
		time.Sleep(duration)
	}
}
