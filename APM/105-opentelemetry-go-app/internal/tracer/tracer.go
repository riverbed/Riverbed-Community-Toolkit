// Aternity Tech-Community
// 105-opentelemetry-go-app
// version: 22.06.3

package tracer

import (
	"context"
	"io"
	"log"
	appconfig "opentelemetry-go-example/internal/config"
	"os"

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
)

func InitTracerProvider() *trace.TracerProvider {
	ctx := context.Background()

	// Desired exporter
	var exp trace.SpanExporter
	var err error
	switch appconfig.Config["OTEL_TRACES_EXPORTER"] {
	case "jaeger":
		exp, err = jaegerExporter()
	case "stdout", "console":
		exp, err = stdouttrace.New(stdouttrace.WithPrettyPrint())
	case "file":
		file, err_file := os.Create("traces.txt")
		if err_file != nil {
			log.Fatal(err_file)
		}
		exp, err = fileExporter(file)
		// Can't close file after this function. Don't bother closing :)
		//defer file.Close()
	case "zipkin":
		exp, err = zipkinExporter()
	case "otlp":
		exp, err = otlpExporter()
	}
	if err != nil {
		log.Fatal(err)
	}

	res, err := resource.New(
		ctx,
		resource.WithAttributes(
			attribute.String("aternity.tech-community.cookbook.id", "105"),
		),
		resource.WithTelemetrySDK(),
		resource.WithOS(),
	)

	if err != nil {
		log.Fatal("Could not set resources: ", err)
	}

	// Register the trace exported with a batcher (TraceProvider)
	// No sampling (i.e. keep every sample :))

	var tp *trace.TracerProvider
	if appconfig.Config["ADD_CONSOLE_EXPORTER"] != "on" {
		tp = trace.NewTracerProvider(
			trace.WithSampler(trace.AlwaysSample()),
			trace.WithBatcher(exp),
			trace.WithResource(res),
		)
	} else {
		// ADD_CONSOLE_EXPORTER, add an exporter to display traces on the stdout (console)
		var exp_console, _ = stdouttrace.New(stdouttrace.WithPrettyPrint())

		tp = trace.NewTracerProvider(
			trace.WithSampler(trace.AlwaysSample()),
			trace.WithBatcher(exp),
			trace.WithResource(res),
			trace.WithBatcher(exp_console),
		)
	}

	otel.SetTracerProvider(tp)

	// The B3 HTTP header propagation
	b3Propagator := b3.New()
	otel.SetTextMapPropagator(b3Propagator)

	return tp
}

// File exporter.
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
		jaeger.WithEndpoint("http://" + appconfig.Config["ATERNITY_COLLECTOR_SERVICE_HOST"] +
			":" + appconfig.Config["JAEGER_PORT"] + appconfig.Config["JAEGER_PATH"])))
}

// Zipkin exporter
func zipkinExporter() (trace.SpanExporter, error) {
	return zipkin.New("http://" + appconfig.Config["ATERNITY_COLLECTOR_SERVICE_HOST"] +
		":" + appconfig.Config["ZIPKIN_PORT"] + appconfig.Config["ZIPKIN_PATH"])
}

// OTLP http exporter
func otlpExporter() (trace.SpanExporter, error) {
	client := otlptracehttp.NewClient(otlptracehttp.WithInsecure(),
		otlptracehttp.WithEndpoint(appconfig.Config["ATERNITY_COLLECTOR_SERVICE_HOST"]+
			":"+appconfig.Config["OTLP_PORT"]),
		otlptracehttp.WithURLPath(appconfig.Config["OTLP_PATH"]))
	return otlptrace.New(context.Background(), client)
}
