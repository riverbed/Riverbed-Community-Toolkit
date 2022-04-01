// trace_app_with_opentelemetry_automatic-instrumentation.js
//
// Aternity Tech-Community
// 107-opentelemetry-autoinstrumentation-nodejs-app
// version: 22.4.1
//
// Intialize OpenTelemetry tracing on a javascript app with OpenTelemetry automatic instrumentation
//
// Usage
//
// - Set environement variable used for OpenTelemetry instrumentation ZipKin exporter
//   * OTEL_SERVICE_NAME. For example: "service107-js"
//   * OTEL_EXPORTER_OTLP_ENDPOINT. For example: localhost:4317 or aternity-opentelemetry-collector:4317
//
// - Run the app with tracing:
//   node -r ./trace_app_with_opentelemetry_automatic-instrumentation.js
//
// Example in PowerShell
//
//   $env:OTEL_SERVICE_NAME="service107-js"
//   $env:OTEL_EXPORTER_OTLP_ENDPOINT="aternity-opentelemetry-collector:4317"
//   node -r ./trace_app_with_opentelemetry_automatic-instrumentation.js app.js

'use strict';

const { diag, DiagConsoleLogger, DiagLogLevel } = require("@opentelemetry/api");
const { NodeTracerProvider } = require("@opentelemetry/sdk-trace-node");
const { Resource } = require('@opentelemetry/resources');
const { SemanticResourceAttributes } = require('@opentelemetry/semantic-conventions');
const { SimpleSpanProcessor } = require("@opentelemetry/sdk-trace-base");
const { registerInstrumentations } = require("@opentelemetry/instrumentation");
const { HttpInstrumentation } = require("@opentelemetry/instrumentation-http");
const { GrpcInstrumentation } = require("@opentelemetry/instrumentation-grpc");

const { OTLPTraceExporter } = require('@opentelemetry/exporter-trace-otlp-grpc');
const { getNodeAutoInstrumentations  } = require("@opentelemetry/auto-instrumentations-node");

const provider = new NodeTracerProvider({
  resource: new Resource({
     [SemanticResourceAttributes.SERVICE_NAME]: process.env.OTEL_SERVICE_NAME || "service-js",
  }),
  instrumentations: [getNodeAutoInstrumentations()]
});

diag.setLogger(new DiagConsoleLogger(), DiagLogLevel.ALL);

provider.addSpanProcessor(
  new SimpleSpanProcessor(
    new OTLPTraceExporter()
  )
);

provider.register();

registerInstrumentations({
  instrumentations: [
    new HttpInstrumentation(),
    new GrpcInstrumentation(),
  ],
});

console.log("OpenTelemetry tracing initialized with OTLP-gRPC automatic instrumentation");
