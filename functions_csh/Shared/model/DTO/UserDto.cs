using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Model;



public class UserDto
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public int? Id { get; set;}
    public string? mail { get; set; }
    public string? username { get ; set; }
    public List<EventDto> Events {get; set;} = [];
}