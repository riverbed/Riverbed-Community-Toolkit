// trace_app_with_opentelemetry_automatic-instrumentation.js
//
// Riverbed-Community-Toolkit
// 107-opentelemetry-autoinstrumentation-nodejs-app
// version: 24.10.4
//
// Intialize OpenTelemetry tracing on a javascript app with OpenTelemetry automatic instrumentation
//
// Usage
//
// - Set environement variable used for OpenTelemetry instrumentation ZipKin exporter
//   * OTEL_SERVICE_NAME. For example: "service107-js"
//   * OTEL_EXPORTER_OTLP_ENDPOINT. For example: http://localhost:4317 or http://riverbed-apm-opentelemetry-collector:4317
//
// - Run the app with tracing:
//   node -r ./trace_app_with_opentelemetry_automatic-instrumentation.js app.js
//
// Example in PowerShell
//
//   $env:OTEL_SERVICE_NAME="service107-js"
//   $env:OTEL_EXPORTER_OTLP_ENDPOINT="riverbed-apm-opentelemetry-collector:4317"
//   node -r ./trace_app_with_opentelemetry_automatic-instrumentation.js app.js

'use strict';

const { NodeTracerProvider } = require('@opentelemetry/sdk-trace-node');
const { getNodeAutoInstrumentations } = require("@opentelemetry/auto-instrumentations-node");
const { Resource } = require('@opentelemetry/resources');
const { SemanticResourceAttributes } = require('@opentelemetry/semantic-conventions');
const { SimpleSpanProcessor } = require("@opentelemetry/sdk-trace-base");
const { OTLPTraceExporter } = require('@opentelemetry/exporter-trace-otlp-grpc');

const { diag, DiagConsoleLogger, DiagLogLevel } = require("@opentelemetry/api");

diag.setLogger(new DiagConsoleLogger(), DiagLogLevel.NONE);

const provider = new NodeTracerProvider({
  resource: new Resource({
     [SemanticResourceAttributes.SERVICE_NAME]: process.env.OTEL_SERVICE_NAME || "service-js",
  }),
  instrumentations: [getNodeAutoInstrumentations()]
});

provider.addSpanProcessor(
  new SimpleSpanProcessor(
    new OTLPTraceExporter()
  )
);

provider.register();

console.log("OpenTelemetry tracing initialized with OTLP-gRPC automatic instrumentation");
