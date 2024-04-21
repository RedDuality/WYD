using Model;
using Database;
using Microsoft.EntityFrameworkCore;


namespace Controller;
public class UserController
{

    WydDbContext db;

    public UserController(){
        db = new WydDbContext();
    }

    public User Get(int id)
    {
        using (db)
        {
            User user = db.Users.First(u => u.Id == id);
            if(user != null)
                return user;
            else
                throw new Exception("No user found");
        }
        throw new Exception("Error while fetching user data");
    }

    public User Save(User user)
    {
        db.Users.AddRange(user);
        db.SaveChanges();
        //TODO save on the User_Event Table
        return user;
    }

    public User Update(int id, User newUser)
    {
        User u = db.Users.First( user => user.Id == id);
        if(u != null){
            u.username = newUser.username;
            db.SaveChanges();
            return u;
        }
        throw new Exception("User not found");
    }
}