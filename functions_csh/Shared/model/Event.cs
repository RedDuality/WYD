using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Newtonsoft.Json;


namespace Model;

[Table("Events")]
public class Event
{
    public DateTime startTime { get; set; }
    public DateTime endTime { get; set; }
    public Boolean? isAllDay{ get; set; } = false;
    public string? color { get; set; }
    public string? startTimeZone { get; set; }
    public string? endTimeZone { get; set; }
    public string? recurrenceRule { get; set; }
    public string? notes { get; set; }
    public string? location  { get; set; }
    public int? recurrenceId{ get; set; }
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public int? Id { get; set; }

    [NotMapped]
    public string? link { get; set; }
    public string? subject { get ; set; }

    //[JsonIgnore]
    public List<User> Users { get; set;} = [];

    public List<UserEvent> UserEvents {get; set;} = [];
}