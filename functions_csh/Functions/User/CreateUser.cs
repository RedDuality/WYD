using Controller;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using Model;
using Newtonsoft.Json;
using System.Data.SqlClient;

namespace My.Functions
{
    public class CreateUser
    {
        private readonly ILogger<CreateUser> _logger;

        private static UserController? _userController;

        public CreateUser(ILogger<CreateUser> logger)
        {
            _logger = logger;
            _userController = new UserController();
        }

        [Function("CreateUser")]
        public static IActionResult Run([HttpTrigger(AuthorizationLevel.Function, "get", "post")] HttpRequest req, FunctionContext executionContext)
        {
            if (_userController == null)
                _userController = new UserController();
            User user = new User
            {
                username = "first"
            };

            User u = _userController.Save(user);

            string result = JsonConvert.SerializeObject(u);
            return new OkObjectResult(result);
        }
    }
}
