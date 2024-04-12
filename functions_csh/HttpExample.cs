using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using System.Data.SqlClient;

namespace My.Functions
{
    public class HttpExample
    {
        private readonly ILogger<HttpExample> _logger;

        public HttpExample(ILogger<HttpExample> logger)
        {
            _logger = logger;
        }

        [Function("HttpExample")]
        public static IActionResult Run([HttpTrigger(AuthorizationLevel.Function, "get", "post")] HttpRequest req, FunctionContext executionContext)
        {
            string connectionString = "Server=tcp:wyddb.database.windows.net,1433;" +
                                    "Initial Catalog=wyddb1;Persist Security Info=False;" + "User ID=wydadmin;Password=password_1;" +
                                    "MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30";



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
        }
    }
}
