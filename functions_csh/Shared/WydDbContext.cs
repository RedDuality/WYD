
using Microsoft.EntityFrameworkCore;
using Model;

namespace Database;
public class WydDbContext : DbContext
{


    private string _connectionString = "Server=tcp:wydreldbserver.database.windows.net,1433;"+
        "Initial Catalog=Wydreldb;Persist Security Info=False;"+ 
        "User ID=wydadmin;Password=password_1;"+
        "MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;";

    public DbSet<Event> Events { get; set; }
    public DbSet<User> Users { get; set; }
    public DbSet<UserEvent> UserEvents { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        optionsBuilder.UseSqlServer(_connectionString);
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Event>().HasMany(e => e.Users).WithMany(u => u.Events).UsingEntity<UserEvent>();

        //modelBuilder.Entity<Event>().Property(p => p.Id).ValueGeneratedOnAdd().Metadata.SetBeforeSaveBehavior(PropertySaveBehavior.Ignore);
        //modelBuilder.Entity<User>().ToTable("User");
        //.Property(p => p.Id).ValueGeneratedOnAdd().Metadata.SetBeforeSaveBehavior(PropertySaveBehavior.Ignore);
        //modelBuilder.Entity<UserEvent>().ToTable("User_Event");
    }
}