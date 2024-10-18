// Riverbed-Community-Toolkit
// 105-opentelemetry-go-app
// version: 22.06.3

package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	appconfig "opentelemetry-go-example/internal/config"
	apphandler "opentelemetry-go-example/internal/handler"
	apptracer "opentelemetry-go-example/internal/tracer"
	"os"
	"strconv"

	"go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp"
)

func setup(name string, handlerFunction http.HandlerFunc, port uint16) {
	tp := apptracer.InitTracerProvider()
	defer func() {
		if err := tp.Shutdown(context.Background()); err != nil {
			log.Fatal(err)
		}
	}()

	wrappedHandler := otelhttp.NewHandler(handlerFunction, name+"-handler")

	http.Handle("/", wrappedHandler)

	log.Println("Starting ", name, " at :", port)
	portString := fmt.Sprintf(":%d", port)
	log.Fatal(http.ListenAndServe(portString, nil))
}

func main() {

	// Usage
	if len(os.Args) != 2 {
		fmt.Printf("Usage: %s <frontend|backend>", os.Args[0])
		os.Exit(1)
	}

	// Do config
	appconfig.SetupConfig()

	if os.Args[1] == "frontend" {
		feP, _ := strconv.Atoi(appconfig.Config["FRONTEND_SERVICE_PORT"])
		setup("frontend", apphandler.FrontendHandler(), uint16(feP))
	} else if os.Args[1] == "backend" {
		beP, _ := strconv.Atoi(appconfig.Config["BACKEND_SERVICE_PORT"])
		setup("backend", apphandler.BackendHandler(), uint16(beP))
	}
}
