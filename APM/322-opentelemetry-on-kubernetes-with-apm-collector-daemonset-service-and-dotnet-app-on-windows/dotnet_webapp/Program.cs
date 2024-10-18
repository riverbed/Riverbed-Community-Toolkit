// Program.cs
// 23.9.230915
// Riverbed-Community-Toolkit (https://github.com/riverbed/Riverbed-Community-Toolkit)
//
// Webapp instrumented with OpenTelemetry

using OpenTelemetry.Trace;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddRazorPages();
builder.Services.AddHttpClient();

////////////////////////////////////////////////////////////////////////
// Add OpenTelemetry instrumentation
builder.Services.AddOpenTelemetry()
  .WithTracing(tracerProviderBuilder => tracerProviderBuilder
    .AddHttpClientInstrumentation()
    .AddAspNetCoreInstrumentation()
    .AddOtlpExporter()
    );
////////////////////////////////////////////////////////////////////////

var app = builder.Build();

app.UseStaticFiles();

app.UseRouting();

app.UseAuthorization();

app.MapRazorPages();

app.Run();
