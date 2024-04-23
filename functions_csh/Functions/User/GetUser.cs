using Controller;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using Model;
using Newtonsoft.Json;

namespace Functions
{
    public class GetUser
    {
        private readonly ILogger<GetUser> _logger;

        private readonly UserController _userController;

        public GetUser(ILogger<GetUser> logger)
        {
            _logger = logger;
            _userController = new UserController();
        }

        [Function("GetUser")]
        public IActionResult Run([HttpTrigger(AuthorizationLevel.Function, "get", Route = "GetUser/{id}")] HttpRequest req, string id)
        {
            int userId;
            try {
                userId = Int32.Parse(id);
            }catch(FormatException){
                return new BadRequestObjectResult("Id Format wrong");
            }

            try {
                User u = _userController.Get(userId);
                string result = JsonConvert.SerializeObject(u);
                return new OkObjectResult(result);
            }
            catch (InvalidOperationException)
            {
                return new NotFoundObjectResult("User not found");
            }

        }
    }
}
