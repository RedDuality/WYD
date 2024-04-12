using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using System.Data.SqlClient;


using System.IO;
using System.Text;
using System.Threading.Tasks;

namespace My.Functions
{
    public class SaveExam
    {
        private readonly ILogger<SaveExam> _logger;

        public SaveExam(ILogger<SaveExam> logger)
        {
            _logger = logger;
        }

        [Function("SaveExam")]
        public static async Task<IActionResult> Run([HttpTrigger(AuthorizationLevel.Anonymous, "get", "post")] HttpRequestData req, FunctionContext executionContext)
        {
            string connectionString = "Server=tcp:wyddb.database.windows.net,1433;" +
                                    "Initial Catalog=wyddb1;Persist Security Info=False;" + "User ID=wydadmin;Password=password_1;" +
                                    "MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30";


            string requestBody;
            using (StreamReader reader = new StreamReader(req.Body, Encoding.UTF8))
            {
                requestBody = await reader.ReadToEndAsync();
            }


            // Return the request body as the response


            
            return new OkObjectResult(requestBody);
            //dynamic data = JsonConvert.DeserializeObject(requestBody);
            // Extract the 'json' query parameter which contains the JSON object
            //var jsonString = queryParams["json"];
            /*
            try
            {
                using (SqlConnection connection = new SqlConnection(connectionString))
                {
                    string insertQuery = "INSERT INTO dbo.Event (isAllDay, subject) VALUES (@Value1, @Value2)";

                    connection.Open();

                    //return new OkObjectResult("OKY");
                    using (SqlCommand command = new SqlCommand(insertQuery, connection))
                    {
                        // Provide values for the parameters
                        command.Parameters.AddWithValue("@Value1", 0);
                        command.Parameters.AddWithValue("@Value2", "prova1");

                        // Execute the query
                        int rowsAffected = command.ExecuteNonQuery();
                        return new OkObjectResult($"Rows affected: {rowsAffected}");
                    }
                }
            }
            catch (SqlException ex)
            {
                Console.WriteLine($"Connection failed: {ex.Message}");
                return new OkObjectResult(ex.Message);
            }
            //return new OkObjectResult("Welcome to Azure Functions!");
            */
        }
    }
}
