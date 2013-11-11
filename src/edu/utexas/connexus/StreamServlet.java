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
import com.googlecode.objectify.ObjectifyService;

import static com.googlecode.objectify.ObjectifyService.ofy;

public class StreamServlet extends HttpServlet{
    static {
        ObjectifyService.register(Stream.class);
        ObjectifyService.register(Subscription.class);
        ObjectifyService.register(CImage.class);
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
        if (action.equals("/delete")) {
            String[] streamIds = req.getParameterValues("stream_id");
            System.out.println(streamIds.length);
            printWriter.println(streamIds.length);
            for (int ind = 0; ind < streamIds.length; ind ++) {
                Stream stream = getStream(user, streamIds[ind]);
                deleteStream(stream);
                printWriter.println("success");
            }
        } else {
            String name = req.getParameter("name");
            String tags = req.getParameter("tags");
            String coverUrl = req.getParameter("cover");
            String subscriberEmails = req.getParameter("subscriber-emails");
            String subscriberMessage = req.getParameter("subscriber-message");
            if (streamNameExists(name)) {
                printWriter.println("Stream name exists");
            } else {
                Stream stream = new Stream(user, name, tags, coverUrl, subscriberEmails, subscriberMessage);
                ofy().save().entity(stream).now();
                printWriter.println(stream.getJSON());
            }
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
            Stream stream = ofy().load().type(Stream.class).id(Long.parseLong(req.getParameter("id"))).get();
            stream.view();
            ofy().save().entity(stream).now();
            printWriter.println(stream.toString());
        } else if (action.equals("/search")) {
            String query = req.getParameter("query");
            List<String> streamIds = SearchIndex.search(query);
            List<Stream> results = new ArrayList<Stream>();
            if ((streamIds == null) || streamIds.isEmpty()) {
                
            } else {
                for (String streamId : streamIds) {
                    Stream stream = ofy().load().type(Stream.class).id(Long.parseLong(streamId)).get();
                    results.add(stream);
                    if (results.size() == 20) {
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
        } else if (action.equals("/rank")) {
            rankStreamViews();
        } else if (action.equals("/trending")) {
            List<Stream> streams = ofy().load().type(Stream.class).list();
            Collections.sort(streams, Stream.RankComparator);
            printWriter.println(streams.toString());
        } else {
            List<Stream> streams = ofy().load().type(Stream.class).list();
            Collections.sort(streams);
            Collections.reverse(streams);
            printWriter.println(streams.toString());
        }
    }

    public Stream getStream(User user, String streamId) {
        Stream stream = ofy().load().type(Stream.class).id(new Long(streamId)).get();
        return stream;
    }
    
    public void deleteStream(Stream stream) {
        String streamId = stream.getId();
        List<CImage> cimages = ofy().load().type(CImage.class).list();
        Collections.sort(cimages);
        Collections.reverse(cimages);
        for (Iterator<CImage> it = cimages.iterator(); it.hasNext();) {
            CImage cimage= it.next();
            if (!cimage.streamId.equals(streamId)) {
                ofy().delete().entity(cimage);
            }
        }
        List<Subscription> subscriptions = ofy().load().type(Subscription.class).list();
        for (Subscription subscription: subscriptions) {
            if (subscription.getStreamId().equals(streamId)) {
                ofy().delete().entity(subscription);
            }
        }
        ofy().delete().entity(stream);
    }
    
    public void rankStreamViews() {
        List<Stream> streams = ofy().load().type(Stream.class).list();
        Collections.sort(streams, Stream.ViewsComparator);
        Integer rank = 1;
        for (Iterator<Stream> it = streams.iterator(); it.hasNext();) {
            Stream stream = it.next();
            stream.setRank(rank);
            ofy().save().entity(stream).now();
            rank++;
        }
    }
    
    public boolean streamNameExists(String name) {
        List<Stream> streams = ofy().load().type(Stream.class).list();
        for (Iterator<Stream> it = streams.iterator(); it.hasNext();) {
            Stream stream = it.next();
            if (stream.getName().toLowerCase().equals(name.toLowerCase())) {
                return true;
            }
        }
        return false;
    }
}
