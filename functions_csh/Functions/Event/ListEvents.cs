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

namespace My.Functions
{
    public class ListEvents
    {
        private readonly ILogger<ListEvents> _logger;
        private static EventController? _eventController;

        public ListEvents(ILogger<ListEvents> logger)
        {
            _logger = logger;
            _eventController = new EventController();
        }

        [Function("ListEvents")]
        public static IActionResult Run([HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "ListEvents/{userid}")] HttpRequestData req, int userId, FunctionContext executionContext)
        {

            if (_eventController == null)
            {
                _eventController = new EventController();
            }

            var eventi = _eventController.GetEvents(1);
            string result = JsonSerializer.Serialize(eventi);

            Console.WriteLine(result);


            return new OkObjectResult(result);
            
        }
    }
}
