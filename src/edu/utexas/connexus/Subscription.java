package edu.utexas.connexus;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Queue;

import com.google.appengine.api.users.User;
import com.google.appengine.labs.repackaged.org.json.JSONException;
import com.google.appengine.labs.repackaged.org.json.JSONObject;
import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Id;

@Entity
public class Subscription implements Comparable<Subscription> {
    @Id Long id;
    User user;
    String streamId;
    Date createdOn;
    
    private Subscription() {}
    
    public Subscription(User user, String streamId) {
        this.user = user;
        this.streamId = streamId;
        this.createdOn = new Date();
    }
    
    public JSONObject getJSON() {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put("id", id);
            jsonObject.put("userNickname", user.getNickname());
            jsonObject.put("streamId", streamId);
            jsonObject.put("createdOn", createdOn.toString());
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return jsonObject;
    }
    
    public User getUser() {
        return user;
    }
    
    public String getStreamId() {
        return streamId;
    }
    
    public String toString() {
        return getJSON().toString();
    }
    
    @Override
    public int compareTo(Subscription other) {
        if (createdOn.after(other.createdOn)) {
            return 1;
        } else if (createdOn.before(other.createdOn)) {
            return -1;
        } else {
            return 0;
        }
    }
}
