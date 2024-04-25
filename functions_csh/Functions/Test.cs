using Controller;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using Model;
using Newtonsoft.Json;

namespace My.Functions
{
    public class Test
    {
        private readonly ILogger<Test> _logger;

        private static UserController? _userController;

        public Test(ILogger<Test> logger)
        {
            _logger = logger;
            _userController = new UserController();
        }

        //[Function("Test")]
        public static IActionResult Run([HttpTrigger(AuthorizationLevel.Anonymous, "get", "post")] HttpRequest req, FunctionContext executionContext)
        {
            //string requestBody = """{"startTime":"2024-04-12T17:16:27.526", "endTime":"2024-04-12T19:16:27.526", "isAllDay":false, "subject":"Meeting", "color":"ff2196f3","startTimeZone":"","endTimeZone":"","recurrenceRule":"FREQ=DAILY;INTERVAL=1;COUNT=10","notes":"notes","location":"","resourceIds":["0001","0002"],"recurrenceId":null,"id":345246336,"link":"linkciao"}""";


            string result = "null";/*
            List<Event>? myevent = JsonConvert.DeserializeObject<List<Event>>(requestBody);
            if (myevent != null)
            {
                List<Event> ciao = _eventController.Save(myevent, 1);
                result = JsonConvert.SerializeObject(ciao);
            }
            

            string result = JsonConvert.SerializeObject(u);*/
            return new OkObjectResult(result);
        }
    }
}
