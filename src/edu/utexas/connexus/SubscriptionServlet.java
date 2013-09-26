package edu.utexas.connexus;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.users.User;
import com.google.appengine.api.users.UserServiceFactory;
import com.google.appengine.api.users.UserService;
import com.google.appengine.labs.repackaged.org.json.JSONArray;
import com.google.appengine.labs.repackaged.org.json.JSONObject;
import com.googlecode.objectify.ObjectifyService;

import static com.googlecode.objectify.ObjectifyService.ofy;


public class SubscriptionServlet extends HttpServlet{
    static {
        ObjectifyService.register(Subscription.class);
        ObjectifyService.register(Stream.class);
    }
    static ExecutorService exec = Executors.newCachedThreadPool();
    
    private static final long serialVersionUID = 1L;
    
    public void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        
        UserService userService = UserServiceFactory.getUserService();
        User user = userService.getCurrentUser();
        
        req.setCharacterEncoding("utf8");
        
        String streamId = req.getParameter("stream_id");
        
        if (!exists(user, streamId)) {
            Subscription subscription = new Subscription(user, streamId);
            
            ofy().save().entity(subscription).now();
            
            resp.setContentType("application/json");
            PrintWriter printWriter = resp.getWriter();
            printWriter.println(subscription.getJSON());
        }
    }
    
    public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        req.setCharacterEncoding("utf8");
        resp.setContentType("application/json");
        PrintWriter printWriter = resp.getWriter();
        
        UserService userService = UserServiceFactory.getUserService();
        User user = userService.getCurrentUser();
        
        
        String action = req.getPathInfo();
        if (action.startsWith("/show")) {
            List<Subscription> subscriptions = ofy().load().type(Subscription.class).list();
            List<Stream> streams = new ArrayList<Stream>();
            for (Subscription subscription: subscriptions) {
                if (!subscription.getUser().equals(user)) {
                    subscriptions.remove(subscription);
                } else {
                    Stream stream = ofy().load().type(Stream.class).id(new Long(subscription.getStreamId())).get();
                    streams.add(stream);
                }
            }
            printWriter.println(streams.toString());
        } else if (action.equals("/delete")) {
            
        } else if (action.equals("/exists")) {
            String streamId = req.getParameter("stream_id");
            printWriter.println(exists(user, streamId));
        }else {

        }
    }
    
    public boolean exists(User user, String streamId) {
        List<Subscription> subscriptions = ofy().load().type(Subscription.class).list();
        for (Subscription subscription: subscriptions) {
            if (subscription.getUser().equals(user) && subscription.getStreamId().equals(streamId)) {
                return true;
            }
        }
        return false;
    }

}
