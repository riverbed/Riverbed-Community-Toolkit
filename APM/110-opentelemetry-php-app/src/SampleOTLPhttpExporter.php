<?php

# SampleOTLPhttpExporter.php
#
# Riverbed-Community-Toolkit
# 110-opentelemetry-php-app
# version: 23.7.7
#
# Sample app instrumented with OpenTelemetry (https://opentelemetry.io/)
#
# Configured using OpenTelemetry environment variables:
#   * OTEL_SERVICE_NAME set with service name for example, "service110-php"
#   * OTEL_EXPORTER_OTLP_TRACES_ENDPOINT set with OTLP http endpoint for example http://aternity-opentelemetry-collector:4318/v1/traces

############################################

## OpenTelemetry initialization

declare(strict_types=1);
require __DIR__ . '/vendor/autoload.php';

use GuzzleHttp\Client;
use GuzzleHttp\Psr7\HttpFactory;
use OpenTelemetry\Contrib\Otlp\OtlpHttpTransportFactory;
use OpenTelemetry\Contrib\Otlp\SpanExporter ;
use OpenTelemetry\SDK\Common\Attribute\Attributes;
use OpenTelemetry\SDK\Trace\SpanProcessor\SimpleSpanProcessor;
use OpenTelemetry\SDK\Trace\TracerProvider;

$transport = (new OtlpHttpTransportFactory())->create(getenv("OTEL_EXPORTER_OTLP_TRACES_ENDPOINT"), 'application/x-protobuf');
$exporter = new SpanExporter($transport);

$tracerProvider =  new TracerProvider(
    new SimpleSpanProcessor(
        $exporter
    )
);

$tracer = $tracerProvider->getTracer('cookbook-tracer');

############################################

## App with manual instrumentation

echo 'Starting Sample app instrumented with OpenTelemetry, exporting OTLP http telemetry to '. getenv("OTEL_EXPORTER_OTLP_TRACES_ENDPOINT") ;

$root = $tracer->spanBuilder('root')->startSpan();
$root->setAttribute('cookbook', '110')->setAttribute('sample', 'OTLPhttpExporter');
$scope = $root->activate();

echo PHP_EOL . "<br>" ;

for ($i = 1; $i < 6; $i++) {
    
    echo "Span: $i" . PHP_EOL . "<br>" ;

    $span = $tracer->spanBuilder('loop-' . $i)->startSpan();

    sleep(random_int(1,2));

    $span->end();
}

$root->end();
$scope->detach();

echo 'Complete!' . PHP_EOL;

############################################

## OpenTelemetry shutdown

$tracerProvider->shutdown();
