<?php

# SampleZipkinExporter.php
#
# Aternity Tech-Community
# 110-opentelemetry-php-app
# version: 22.4.11
#
# Sample app instrumented with OpenTelemetry (https://opentelemetry.io/)
# 
# Configured using OpenTelemetry environment variables:
#   * OTEL_SERVICE_NAME set with service name for example, "service110-php"
#   * OTEL_EXPORTER_ZIPKIN_ENDPOINT set with zipkin endpoint for example http://aternity-opentelemetry-collector:9411/api/v2/spans

declare(strict_types=1);
require __DIR__ . '/vendor/autoload.php';

use GuzzleHttp\Client;
use GuzzleHttp\Psr7\HttpFactory;
use OpenTelemetry\Contrib\Zipkin\Exporter as ZipkinExporter;
use OpenTelemetry\SDK\Common\Attribute\Attributes;
use OpenTelemetry\SDK\Trace\SpanProcessor\SimpleSpanProcessor;
use OpenTelemetry\SDK\Trace\TracerProvider;

############################################

## OpenTelemetry initialization

$OTEL_EXPORTER_ZIPKIN_ENDPOINT = getenv("OTEL_EXPORTER_ZIPKIN_ENDPOINT");
$OTEL_SERVICE_NAME = getenv("OTEL_SERVICE_NAME");

$zipkinExporter = new ZipkinExporter(
    $OTEL_SERVICE_NAME,
    $OTEL_EXPORTER_ZIPKIN_ENDPOINT,
    new Client(),
    new HttpFactory(),
    new HttpFactory()
);

$tracerProvider =  new TracerProvider(
    new SimpleSpanProcessor(
        $zipkinExporter
    )
);

$tracer = $tracerProvider->getTracer();

############################################

## App with manual instrumentation

echo 'Starting Sample app instrumented with OpenTelemetry, exporting Zipkin telemetry to '. getenv("OTEL_EXPORTER_ZIPKIN_ENDPOINT") ;

$root = $span = $tracer->spanBuilder('root')->startSpan();
$span->activate();

$span->setAttribute('cookbook', '110')
->setAttribute('sample', 'ZipkinExporter');

echo PHP_EOL ;

for ($i = 1; $i < 5; $i++) {
    
    echo "Span: $i" . PHP_EOL ;

    $span = $tracer->spanBuilder('loop-' . $i)->startSpan();

    sleep(random_int(2,4));

    $span->end();
}
$root->end();

echo 'Complete!' . PHP_EOL;
