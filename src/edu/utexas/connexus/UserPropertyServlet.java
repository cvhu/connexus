package edu.utexas.connexus;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Iterator;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.users.User;
import com.google.appengine.api.users.UserServiceFactory;
import com.google.appengine.api.users.UserService;
import com.googlecode.objectify.ObjectifyService;

import static com.googlecode.objectify.ObjectifyService.ofy;


public class UserPropertyServlet extends HttpServlet{
    static {
        ObjectifyService.register(UserProperty.class);
    }
    static ExecutorService exec = Executors.newCachedThreadPool();
    
    private static final long serialVersionUID = 1L;
    
    public void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        
        UserService userService = UserServiceFactory.getUserService();
        User user = userService.getCurrentUser();
        
        req.setCharacterEncoding("utf8");
        resp.setContentType("application/json");
        PrintWriter printWriter = resp.getWriter();
        
        String action = req.getPathInfo();
        if (action.equals("/update")) {
            String property = req.getParameter("property");
            String value = req.getParameter("value");
            System.out.printf("property: %s value: $s\n", property, value);
            UserProperty userProperty = getUserProperty(user, property);
            if (userProperty == null) {
                userProperty = new UserProperty(user, property, value);
            }
            userProperty.setValue(value);
            ofy().save().entity(userProperty).now();
            printWriter.println(userProperty.toString());
        }
    }
    
    public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        UserService userService = UserServiceFactory.getUserService();
        User user = userService.getCurrentUser();
        req.setCharacterEncoding("utf8");
        resp.setContentType("application/json");
        PrintWriter printWriter = resp.getWriter();
        
        String action = req.getPathInfo();
        if (action.startsWith("/show")) {
            String property = req.getParameter("property");
            UserProperty userProperty = getUserProperty(user, property);
            if (userProperty != null) {
                printWriter.println(userProperty.toString());
            } else {
                printWriter.println("undefined");
            }
        }
    }

    public UserProperty getUserProperty(User user, String property) {
        List<UserProperty> userProperties = ofy().load().type(UserProperty.class).list();
        for (Iterator<UserProperty> it = userProperties.iterator(); it.hasNext();) {
            UserProperty userProperty = it.next();
            if (userProperty.isProperty(user, property)) {
                return userProperty;
            }
        }
        return null;
    }
}
