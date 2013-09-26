package edu.utexas.connexus;

import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.List;

import com.google.appengine.api.users.User;
import com.google.appengine.labs.repackaged.org.json.JSONException;
import com.google.appengine.labs.repackaged.org.json.JSONObject;
import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Id;

@Entity
public class Stream implements Comparable<Stream> {
    @Id Long id;
    User user;
    String name;
    String tags;
    String coverUrl;
    String subscriberEmails;
    String subscriberMessage;
    Date createdOn;
    List<Date> viewDates = new ArrayList<Date>();
    
    private Stream() {}
    
    public Stream(User user, String name, String tags, String coverUrl, String subscriberEmails, String subscriberMessage) {
        this.user = user;
        this.name = name;
        this.tags = tags;
        this.coverUrl = coverUrl;
        this.subscriberEmails = subscriberEmails;
        this.subscriberMessage = subscriberMessage;
        this.createdOn = new Date();
    }
    
    public void view() {
        getViewsCount();
        Date now = new Date();
        viewDates.add(now);
        for(Iterator<Date> it = viewDates.iterator(); it.hasNext();) {
            Date view = it.next();
            if (now.getTime() - view.getTime() >= 60*60*1000) {
                it.remove();
            }
        }
        
    }
    
    public int getViewsCount() {
        if (viewDates == null) {
            viewDates = new ArrayList<Date>();
        }
        return viewDates.size();
    }
    
    public User getUser() {
        return user;
    }
    
    public boolean contains(String query) {
        return name.contains(query) || tags.contains(query);
    }
    
    public JSONObject getJSON() {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put("id", id);
            jsonObject.put("userNickname", user.getNickname());
            jsonObject.put("name", name);
            jsonObject.put("tags", tags);
            jsonObject.put("coverUrl", coverUrl);
            jsonObject.put("subscriberEmails", subscriberEmails);
            jsonObject.put("subscriberMessage", subscriberMessage);
            jsonObject.put("createdOn", createdOn.toString());
            jsonObject.put("views", getViewsCount());
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return jsonObject;
    }
    
    public String toString() {
        return getJSON().toString();
    }
    
    @Override
    public int compareTo(Stream other) {
        if (createdOn.getTime() > other.createdOn.getTime()) {
            return 1;
        } else if (createdOn.getTime() < other.createdOn.getTime()) {
            return -1;
        }
        return 0;
    }
    }
