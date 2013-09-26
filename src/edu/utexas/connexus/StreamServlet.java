package edu.utexas.connexus;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Collections;
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
import com.google.appengine.labs.repackaged.org.json.JSONArray;
import com.google.appengine.labs.repackaged.org.json.JSONObject;
import com.googlecode.objectify.ObjectifyService;

import static com.googlecode.objectify.ObjectifyService.ofy;


public class StreamServlet extends HttpServlet{
    static {
        ObjectifyService.register(Stream.class);
    }
    static ExecutorService exec = Executors.newCachedThreadPool();
    
    private static final long serialVersionUID = 1L;
    
    public void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        
        UserService userService = UserServiceFactory.getUserService();
        User user = userService.getCurrentUser();
        
        req.setCharacterEncoding("utf8");
        
        String name = req.getParameter("name");
        String tags = req.getParameter("tags");
        String coverUrl = req.getParameter("cover");
        String subscriberEmails = req.getParameter("subscriber-emails");
        String subscriberMessage = req.getParameter("subscriber-message");
        Stream stream = new Stream(user, name, tags, coverUrl, subscriberEmails, subscriberMessage);
        
        ofy().save().entity(stream).now();
        
        resp.setContentType("application/json");
        PrintWriter printWriter = resp.getWriter();
        printWriter.println(stream.getJSON());
    }
    
    public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        UserService userService = UserServiceFactory.getUserService();
        User user = userService.getCurrentUser();
        req.setCharacterEncoding("utf8");
        resp.setContentType("application/json");
        PrintWriter printWriter = resp.getWriter();
        
        String action = req.getPathInfo();
        if (action.startsWith("/show")) {
            Stream stream = ofy().load().type(Stream.class).id(Long.parseLong(req.getParameter("id"))).get();
            stream.view();
            ofy().save().entity(stream).now();
            printWriter.println(stream.toString());
        } else if (action.equals("/search")) {
            String query = req.getParameter("query");
            List<Stream> streams = ofy().load().type(Stream.class).list();
            Collections.sort(streams);
            Collections.reverse(streams);
            List<Stream> results = new ArrayList<Stream>();
            for (int ind = 0; ind < streams.size(); ind++) {
                Stream stream = streams.get(ind);
                if (stream.contains(query)) {
                    results.add(stream);
                    if (results.size() == 5) {
                        break;
                    }
                }
            }
            printWriter.println(results.toString());
        } else if (action.equals("/mine")) {
            List<Stream> streams = ofy().load().type(Stream.class).list();
            Collections.sort(streams);
            Collections.reverse(streams);
            for (Iterator<Stream> it = streams.iterator(); it.hasNext();) {
                Stream stream= it.next();
                if (!stream.user.equals(user)) {
                    it.remove();
                }
            }
            printWriter.println(streams.toString());
        } else {
            List<Stream> streams = ofy().load().type(Stream.class).list();
            Collections.sort(streams);
            Collections.reverse(streams);
            printWriter.println(streams.toString());
        }
    }

}
