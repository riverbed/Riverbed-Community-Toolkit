using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace dotnet_webapp.Pages;

public class IndexModel : PageModel
{
    private readonly ILogger<IndexModel> _logger;

    private readonly IHttpClientFactory _httpClientFactory;

    public IndexModel(ILogger<IndexModel> logger, IHttpClientFactory httpClientFactory)
    {
        _logger = logger;
        _httpClientFactory = httpClientFactory;
    }

    public void OnGet()
    {
        var url_webservice = Environment.GetEnvironmentVariable("URL_WEBSERVICE") ?? "http://www.riverbed.com";
        var httpClient = _httpClientFactory.CreateClient();
        httpClient.GetStringAsync(url_webservice);
    }
}
