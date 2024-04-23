using Model;
using Database;
using Newtonsoft.Json;
using AutoMapper;


namespace Controller;
public class EventController
{

    WydDbContext db;
    Mapper userMapper;

    public EventController()
    {
        db = new WydDbContext();
        var userMapperConfig = new MapperConfiguration( cfg => {
            cfg.CreateProjection<User,UserDto>();
            cfg.CreateProjection<Event, EventDto>();
            cfg.CreateProjection<UserEvent, UserEventDto>();
            });

        userMapper = new Mapper(userMapperConfig);
    }

    public List<EventDto> GetEvents(int userId)
    {
        using (db)
        {
            var user = userMapper.ProjectTo<UserDto>(db.Users, null).First(u => u.Id == userId);
            return user.Events;
        }
        throw new Exception("Error while fetching event data");

    }

    public Event Create(Event ev, User user)
    {

        using (db)
        {
            var transaction = db.Database.BeginTransaction();
            User uc = new UserController().Get(1);
            ev.Id = null;
            
            db.Events.Add(ev);
            db.SaveChanges();
            ev.Users.Add(uc);
            db.Events.Update(ev);
            db.SaveChanges();
            transaction.Commit();
            return ev;
        }
    }

    public List<Event> Add(List<User> users, List<Event> ev)
    {
        using (db)
        {
            var transaction = db.Database.BeginTransaction();

            ev.ForEach(e=> e.Id = null);
            
            db.Events.AddRange(ev);
            db.SaveChanges();
            ev.ForEach(e => e.Users.AddRange(users));
            db.Events.UpdateRange(ev);
            db.SaveChanges();

            transaction.Commit();
            
            return ev;
        }
    }
}