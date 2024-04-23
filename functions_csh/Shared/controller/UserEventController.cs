using Model;
using Database;


namespace Controller;
public class UserEventController
{

    WydDbContext db;

    public UserEventController(WydDbContext? wydDbContext){
        if(wydDbContext == null)
            db = new WydDbContext();
        else
            db = wydDbContext;
    }

    public List<UserEvent> GetUserEvent(User user )
    {
        using (db)
        {
            var user_events = db.UserEvents.Where(ue => ue.UserId == user.Id).ToList();
            return user_events;
        }
        throw new Exception("Error while fetching user data");
        
    }

    public List<UserEvent> Save(List<UserEvent> userevent)
    {
        db.UserEvents.AddRange(userevent);
        db.SaveChanges();
        //TODO save on the User_Event Table
        return userevent;
    }
}