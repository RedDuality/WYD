using Controller;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using Model;
using Newtonsoft.Json;

namespace Functions
{
    public class CreateUser
    {
        private readonly ILogger<CreateUser> _logger;

        private readonly UserController _userController;

        public CreateUser(ILogger<CreateUser> logger)
        {
            _logger = logger;
            _userController = new UserController();
        }

        [Function("CreateUser")]
        public async Task<IActionResult> Run([HttpTrigger(AuthorizationLevel.Function, "get")] HttpRequest req, FunctionContext executionContext)
        {

            /*
            string requestBody;
            using (StreamReader reader = new StreamReader(req.Body, Encoding.UTF8))
            {
                requestBody = await reader.ReadToEndAsync();
            }
            var user = JsonConvert.DeserializeObject<User>(requestBody);
            */


            User user = new User
            {
                username = "first",
                mail = "first@first.com"
            };

            User u = _userController.Create(user);

            string result = JsonConvert.SerializeObject(u);
            return new OkObjectResult(result);
        }
    }
}
