using Controller;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using Model;
using Newtonsoft.Json;

namespace My.Functions
{
    public class GetUser
    {
        private readonly ILogger<GetUser> _logger;

        private static UserController? _userController;

        public GetUser(ILogger<GetUser> logger)
        {
            _logger = logger;
            _userController = new UserController();
        }

        [Function("GetUser")]
        public static IActionResult Run([HttpTrigger(AuthorizationLevel.Function, "get", "post")] HttpRequest req, FunctionContext executionContext)
        {
            if (_userController == null)
                _userController = new UserController();
            
            User u = _userController.Get(1);
            Console.WriteLine(JsonConvert.SerializeObject(u));
            
            string result = JsonConvert.SerializeObject(u);
            return new OkObjectResult(result);
        }
    }
}
