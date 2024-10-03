// trace_app_with_opentelemetry.js
//
// Aternity Tech-Community
// 104-opentelemetry-zipkin-nodejs-app
// version: 22.2.24
//
// Intialize OpenTelemetry tracing on the javascript app with ZipKin span export
//
// Usage
//
// - Set environement variable used for OpenTelemetry instrumentation ZipKin exporter
//   * OTEL_SERVICE_NAME. For example: "service104-js"
//   * OTEL_EXPORTER_ZIPKIN_ENDPOINT. For example: http://localhost:9411/api/v2/spans or http://aternity-opentelemetry-collector:9411/api/v2/spans
//
// - Run the app with tracing:
//   node -r ./trace_app_with_opentelemetry.js app.js
//
// Example in PowerShell
//
//   $env:OTEL_SERVICE_NAME="service104-js"
//   $env:OTEL_EXPORTER_ZIPKIN_ENDPOINT="http://aternity-opentelemetry-collector:9411/api/v2/spans"
//   node -r ./trace_app_with_opentelemetry.js app.js

'use strict';

const { diag, DiagConsoleLogger, DiagLogLevel } = require("@opentelemetry/api");
const { NodeTracerProvider } = require("@opentelemetry/sdk-trace-node");
const { Resource } = require('@opentelemetry/resources');
const { SemanticResourceAttributes } = require('@opentelemetry/semantic-conventions');
const { SimpleSpanProcessor } = require("@opentelemetry/sdk-trace-base");
const { registerInstrumentations } = require("@opentelemetry/instrumentation");
const { HttpInstrumentation } = require("@opentelemetry/instrumentation-http");
const { GrpcInstrumentation } = require("@opentelemetry/instrumentation-grpc");

const { ZipkinExporter } = require("@opentelemetry/exporter-zipkin");

const provider = new NodeTracerProvider({
  resource: new Resource({
    [SemanticResourceAttributes.SERVICE_NAME]: process.env.OTEL_SERVICE_NAME || "service-js",
  })
});

diag.setLogger(new DiagConsoleLogger(), DiagLogLevel.ALL);

provider.addSpanProcessor(
  new SimpleSpanProcessor(
    new ZipkinExporter()
  )
);

provider.register();

registerInstrumentations({
  instrumentations: [
    new HttpInstrumentation(),
    new GrpcInstrumentation(),
  ],
});

console.log("OpenTelemetry tracing initialized with ZipKin span export");