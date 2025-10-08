var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.MapGet("/", () => "Riverbed Community Toolkit!");

app.Run();
