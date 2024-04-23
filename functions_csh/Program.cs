using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.DependencyInjection;
using Newtonsoft.Json;
using Model;

var host = new HostBuilder()
    .ConfigureFunctionsWebApplication()
    .ConfigureServices(services => {
        services.AddApplicationInsightsTelemetryWorkerService();
        services.ConfigureFunctionsApplicationInsights();
        services.AddLogging();
    })
    
    .Build();
    
JsonConvert.DefaultSettings = () => new JsonSerializerSettings {
     Formatting = Formatting.Indented,
     ReferenceLoopHandling = ReferenceLoopHandling.Ignore
};



host.Run();
