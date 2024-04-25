using Controller;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using System.Text.Json;

namespace Functions
{
    public class ListEvents
    {
        private readonly ILogger<ListEvents> _logger;
        private readonly EventController _eventController;

        public ListEvents(ILogger<ListEvents> logger)
        {
            _logger = logger;
            _eventController = new EventController();
        }

        [Function("ListEvents")]
        public IActionResult Run([HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "ListEvents/{userId}")] HttpRequestData req, string userId, FunctionContext executionContext)
        {
            int id;
            try {
                id = Int32.Parse(userId);
            }catch(FormatException){
                return new BadRequestObjectResult("Id Format wrong");
            }

            var eventi = _eventController.GetEvents(id);
            string result = JsonSerializer.Serialize(eventi);

            Console.WriteLine(result);


            return new OkObjectResult(result);
            
        }
    }
}
