using Newtonsoft.Json;


namespace Model;


public class UserEventDto
{
    [JsonIgnore]
    public int UserId { get; set; }
    public Boolean confirmed { get ; set; } = false;
}