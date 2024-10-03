<?php

# SampleZipkinExporter.php
#
# Aternity Tech-Community
# 110-opentelemetry-php-app
# version: 23.7.7
#
# Sample app instrumented with OpenTelemetry (https://opentelemetry.io/)
# 
# Configured using OpenTelemetry environment variables:
#   * OTEL_SERVICE_NAME set with service name for example, "service110-php"
#   * OTEL_EXPORTER_ZIPKIN_ENDPOINT set with zipkin endpoint for example http://aternity-opentelemetry-collector:9411/api/v2/spans

############################################

## OpenTelemetry initialization

declare(strict_types=1);
require __DIR__ . '/vendor/autoload.php';

use GuzzleHttp\Client;
use GuzzleHttp\Psr7\HttpFactory;
use OpenTelemetry\SDK\Common\Export\Http\PsrTransportFactory;
use OpenTelemetry\Contrib\Zipkin\Exporter as ZipkinExporter;
use OpenTelemetry\SDK\Common\Attribute\Attributes;
use OpenTelemetry\SDK\Trace\SpanProcessor\SimpleSpanProcessor;
use OpenTelemetry\SDK\Trace\TracerProvider;

$OTEL_EXPORTER_ZIPKIN_ENDPOINT = getenv("OTEL_EXPORTER_ZIPKIN_ENDPOINT");
$OTEL_SERVICE_NAME = getenv("OTEL_SERVICE_NAME");

$transport = PsrTransportFactory::discover()->create($OTEL_EXPORTER_ZIPKIN_ENDPOINT, 'application/json');
$exporter = new ZipkinExporter(
    $OTEL_SERVICE_NAME,
    $transport
);

$tracerProvider =  new TracerProvider(
    new SimpleSpanProcessor(
        $exporter
    )
);

$tracer = $tracerProvider->getTracer('cookbook-tracer');

############################################

## App with manual instrumentation

echo 'Starting Sample app instrumented with OpenTelemetry, exporting Zipkin telemetry to '. getenv("OTEL_EXPORTER_ZIPKIN_ENDPOINT") ;

$root = $tracer->spanBuilder('root')->startSpan();
$root->setAttribute('cookbook', '110')->setAttribute('sample', 'ZipkinExporter');
$scope = $root->activate();

echo PHP_EOL . "<br>" ;

for ($i = 1; $i < 10; $i++) {
    
    echo "Span: $i" . PHP_EOL . "<br>" ;

    $span = $tracer->spanBuilder('loop-' . $i)->startSpan();

    sleep(random_int(1,4));

    $span->end();
}

$root->end();
$scope->detach();

echo 'Complete!' . PHP_EOL;

############################################

## OpenTelemetry shutdown

$tracerProvider->shutdown();
