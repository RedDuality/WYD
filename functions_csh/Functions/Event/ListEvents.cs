using Controller;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.Features;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using Microsoft.IdentityModel.Tokens;
using Model;
using System.Data.SqlClient;


using System.IO;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

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