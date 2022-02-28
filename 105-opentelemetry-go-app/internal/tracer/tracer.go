// Aternity Tech-Community
// 105-opentelemetry-go-app

package tracer

import (
	"context"
	"go.opentelemetry.io/contrib/propagators/b3"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/exporters/jaeger"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracehttp"
	"go.opentelemetry.io/otel/exporters/stdout/stdouttrace"
	"go.opentelemetry.io/otel/exporters/zipkin"
	"go.opentelemetry.io/otel/sdk/resource"
	"go.opentelemetry.io/otel/sdk/trace"
	"io"
	"log"
	appconfig "opentelemetry-go-example/internal/config"
	"os"
)

func InitTracerProvider(serviceName string) (*trace.TracerProvider) {
	// The B3 HTTP header propagation
	b3Propagator := b3.New()
	otel.SetTextMapPropagator(b3Propagator)

	// Desired exporter
	var exp trace.SpanExporter
	var err error
	switch appconfig.Config["EXPORTER"] {
	case "jaeger":
		exp, err = jaegerExporter()
	case "file":
		file, err := os.Create(serviceName + "-traces.txt")
		if err != nil {
			log.Fatal(err)
		}
		exp, err = fileExporter(file)
		// Can't close file after this function. Don't bother closing.
		//defer file.Close()
	case "zipkin":
		exp, err = zipkinExporter()
	case "otlp":
		exp, err = otlpExporter()
	}
	if err != nil {
		log.Fatal(err)
	}

	// Set the service name - and any other attributes.
	resources, err := resource.New(
		context.Background(),
		resource.WithAttributes(
			attribute.String("service.name", serviceName),
			attribute.String("library.language", "go"),
		),
	)
	if err != nil {
		log.Fatal("Could not set resources: ", err)
	}

	// Set the main batched tracer provider
	tp := trace.NewTracerProvider(
		trace.WithBatcher(exp),
		trace.WithResource(resources),
	)
	otel.SetTracerProvider(tp)

	return tp
}

// Console exporter.
func fileExporter(w io.Writer) (trace.SpanExporter, error) {
	return stdouttrace.New(
		stdouttrace.WithWriter(w),
		stdouttrace.WithPrettyPrint(),
		stdouttrace.WithoutTimestamps(),
	)
}

// Jaeger exporter
func jaegerExporter() (trace.SpanExporter, error) {
	return jaeger.New(jaeger.WithCollectorEndpoint(
		jaeger.WithEndpoint(appconfig.Config["JAEGER_ENDPOINT"])))
}

// Zipkin exporter
func zipkinExporter() (trace.SpanExporter, error) {
	return zipkin.New(appconfig.Config["ZIPKIN_ENDPOINT"])
}

// OTLP exporter
func otlpExporter() (trace.SpanExporter, error) {
	client := otlptracehttp.NewClient(otlptracehttp.WithInsecure(),
		otlptracehttp.WithEndpoint(appconfig.Config["OTLP_ENDPOINT"]),
		otlptracehttp.WithURLPath(appconfig.Config["OTLP_URL"]))
	return otlptrace.New(context.Background(), client)
}
