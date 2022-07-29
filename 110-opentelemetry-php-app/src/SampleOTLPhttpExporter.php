<?php

# SampleOTLPhttpExporter.php
#
# Aternity Tech-Community
# 110-opentelemetry-php-app
# version: 22.7.30
#
# Sample app instrumented with OpenTelemetry (https://opentelemetry.io/)
#
# Configured using OpenTelemetry environment variables:
#   * OTEL_SERVICE_NAME set with service name for example, "service110-php"
#   * OTEL_EXPORTER_OTLP_ENDPOINT set with OTLP http endpoint for example http://aternity-opentelemetry-collector:4318/v1/traces

############################################

## OpenTelemetry initialization

declare(strict_types=1);
require __DIR__ . '/vendor/autoload.php';

use GuzzleHttp\Client;
use GuzzleHttp\Psr7\HttpFactory;
use OpenTelemetry\Contrib\OtlpHttp\Exporter as OTLPExporter;
use OpenTelemetry\SDK\Common\Attribute\Attributes;
use OpenTelemetry\SDK\Trace\SpanProcessor\SimpleSpanProcessor;
use OpenTelemetry\SDK\Trace\TracerProvider;

$exporter = new OTLPExporter(
    new Client(),
    new HttpFactory(),
    new HttpFactory()
);

$tracerProvider =  new TracerProvider(
    new SimpleSpanProcessor(
        $exporter
    )
);
$tracer = $tracerProvider->getTracer('cookbook-tracer');

############################################

## App with manual instrumentation

echo 'Starting Sample app instrumented with OpenTelemetry, exporting OTLP http telemetry to '. getenv("OTEL_EXPORTER_OTLP_ENDPOINT") ;

$root = $span = $tracer->spanBuilder('root')->startSpan();
$span->activate();

$span->setAttribute('cookbook', '110')
->setAttribute('sample', 'OTLPhttpExporter');

echo PHP_EOL ;

for ($i = 1; $i < 6; $i++) {
    
    echo "Span: $i" . PHP_EOL ;

    $span = $tracer->spanBuilder('loop-' . $i)->startSpan();

    sleep(random_int(1,2));

    $span->end();
}
$root->end();

echo 'Complete!' . PHP_EOL;
