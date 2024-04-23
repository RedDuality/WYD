using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Newtonsoft.Json;


namespace Model;


[Table("Users")]
public class User
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public int? Id { get; set;}
    public string? mail { get; set; }
    public string? username { get ; set; }
    
    [JsonIgnore]
    public List<Event> Events {get; set;} = [];
    [JsonIgnore]
    public List<UserEvent> UserEvents {get; set;} = [];
}