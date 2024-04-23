

using Controller;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using Model;
using Newtonsoft.Json;



namespace Functions
{
    public class CreateEvent
    {
        private readonly ILogger<CreateEvent> _logger;
        private readonly EventController _eventController;

        public CreateEvent(ILogger<CreateEvent> logger)
        {
            _logger = logger;
            _eventController = new EventController();
        }

        [Function("CreateEvent")]
        public async Task<IActionResult> Run([HttpTrigger(AuthorizationLevel.Anonymous, "get", "post")] HttpRequestData req, FunctionContext executionContext)
        {

            /*
            string requestBody;
            using (StreamReader reader = new StreamReader(req.Body, Encoding.UTF8))
            {
                requestBody = await reader.ReadToEndAsync();
            }*/
            string requestBody = """{"startTime":"2024-04-12T17:16:27.526", "endTime":"2024-04-12T19:16:27.526", "isAllDay":false, "subject":"Meeting", "color":"ff2196f3","startTimeZone":"","endTimeZone":"","recurrenceRule":"FREQ=DAILY;INTERVAL=1;COUNT=10","notes":"notes","location":"","resourceIds":["0001","0002"],"recurrenceId":null,"id":345246336,"link":"linkciao"}""";


            string result = "null";
            var myevent = JsonConvert.DeserializeObject<Event>(requestBody);
            if (myevent != null)
            {
                User uc = new UserController().Get(1);
                Event ciao = _eventController.Create(myevent, uc);
                result = JsonConvert.SerializeObject(ciao);
                return new OkObjectResult(result);
            }
            return new BadRequestObjectResult("Bad Json Formatting");

        }
    }
}
