package edu.utexas.connexus;

import java.io.IOException;
import java.util.Collections;
import java.util.Date;
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


public class MailServlet extends HttpServlet{
    static {
        ObjectifyService.register(UserProperty.class);
        ObjectifyService.register(Stream.class);
    }
    static ExecutorService exec = Executors.newCachedThreadPool();
    
    private static final long serialVersionUID = 1L;

    public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        req.setCharacterEncoding("utf8");
        resp.setContentType("application/json");
        System.out.println("sending trending mail");
        String action = req.getPathInfo();
        
        if (action.startsWith("/trending")) {
            sendTrendingMails();
        }
    }
    
    public void sendTrendingMails() throws IOException {
        SendMail sendMail = new SendMail();
        List<UserProperty> userProperties = ofy().load().type(UserProperty.class).list();
        for (Iterator<UserProperty> it = userProperties.iterator(); it.hasNext();) {
            UserProperty userProperty = it.next();
            if (userProperty.getProperty().equals("trendUpdateRate")) {
                sendTrendingMail(sendMail, userProperty);
            }
        }
    }
    
    public void sendTrendingMail(SendMail sendMail, UserProperty updateRate) throws IOException{
        if (updateRate == null) {
//            sendMail.send("vic@cvhu.org", "update rate == null", "test body 2" + updateRate);
            return;
        }
        String rate = updateRate.getValue();
        if (rate == null) {
//            sendMail.send("vic@cvhu.org", " rate == null", "test body 2");
            return;
        }
        if (rate.equals("no_report")) {
//            sendMail.send("vic@cvhu.org", "no report", "test body 2");
            return;
        }
        
        User user = updateRate.getUser();
        
        Long boundary = new Long(0L);
        if (rate.equals("5_min")) {
            boundary = new Long(5*60*1000L);
        } else if (rate.equals("1_hour")) {
            boundary = new Long(60*60*1000L);
        } else if (rate.equals("1_day")) {
            boundary = new Long(24*60*60*1000L);
        }
        UserProperty lastUpdate = getUserProperty(user, "lastTrendingUpdate");
        if (lastUpdate == null) {
            lastUpdate = new UserProperty(user, "lastTrendingUpdate", "0");
        }
        String last = lastUpdate.getValue();
        Long lastLong = new Long(last);
        Date now = new Date();
        Long nowLong = now.getTime();
//        sendMail.send("vic@cvhu.org", "before boundary check", String.format("boundary: %s\n now: %s\n last: %s\n", boundary.toString(), nowLong.toString(), lastLong.toString()));
        if (nowLong - lastLong > boundary) {
            List<Stream> streams = ofy().load().type(Stream.class).list();
            Collections.sort(streams, Stream.RankComparator);
            String mailSubject = "Trending Updates from Connexus";
            StringBuffer sb = new StringBuffer("Trending streams on Connexus: \n \n");
            int counter = 3;
            for (Iterator<Stream> it = streams.iterator(); it.hasNext();) {
                Stream stream = it.next();
                sb.append(String.format("%s [%d views] - http://conn3xus.appspot.com%s \n", stream.getName(), stream.getViewsCount(), stream.getUrl()));
                counter--;
                if (counter == 0) {
                    break;
                }
            }
            
            sb.append("\n \n Enjoy your streams! \n \n Connexus Team");
            String mailBody = sb.toString();
            System.out.println("Sent trending mail to " + lastUpdate.getUserEmail());
            sendMail.send(lastUpdate.getUserEmail(), mailSubject, mailBody);
            lastUpdate.setValue(nowLong.toString());
            ofy().save().entity(lastUpdate).now();
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
