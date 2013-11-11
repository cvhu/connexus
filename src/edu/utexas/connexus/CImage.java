package edu.utexas.connexus;

import java.text.SimpleDateFormat;
import java.util.Date;

import com.google.appengine.api.users.User;
import com.google.appengine.labs.repackaged.org.json.JSONArray;
import com.google.appengine.labs.repackaged.org.json.JSONException;
import com.google.appengine.labs.repackaged.org.json.JSONObject;
import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Id;

@Entity
public class CImage implements Comparable<CImage>{
    @Id Long id;
    User user;
    String streamId;
    String streamName;
    String comments;
    String bkUrl;
    Date createdOn;
    
    private CImage() {}
    
    public CImage(User user, String streamId, String streamName, String comments, String bkUrl) {
        this.user = user;
        this.streamId = streamId;
        this.streamName = streamName;
        this.comments = comments;
        this.bkUrl = bkUrl;
        this.createdOn = new Date();
    }
    
    public JSONObject getJSON() {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put("id", id);
            jsonObject.put("userNickname", getUsername());
            jsonObject.put("streamId", streamId);
            jsonObject.put("streamName", streamName);
            jsonObject.put("comments", comments);
            jsonObject.put("name", comments);
            jsonObject.put("bkUrl", bkUrl);
            jsonObject.put("url", bkUrl);
            jsonObject.put("thumbnailUrl", bkUrl);
            jsonObject.put("deleteUrl", bkUrl);
            jsonObject.put("deleteType", "DELETE");
            jsonObject.put("size", 100);
            jsonObject.put("createdOn", new SimpleDateFormat("h:mm a MMM d").format(createdOn));
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return jsonObject;
    }
    
    public String getUsername() {
        if (user == null) {
            return "anonymous";
        }
        return user.getNickname();
    }
    
    @Override
    public String toString() {
        return getJSON().toString();
    }
    
    public String uploaderToString() {
        try {
            JSONObject jsonObject = new JSONObject();
            JSONArray jsonArray = new JSONArray(getJSON());
            jsonObject.put("files", jsonArray);
            return jsonObject.toString();
        } catch (JSONException e) {
            e.printStackTrace();
            return null;
        }
    }

    @Override
    public int compareTo(CImage other) {
        if (createdOn.getTime() > other.createdOn.getTime()) {
            return 1;
        } else if (createdOn.getTime() < other.createdOn.getTime()) {
            return -1;
        }
        return 0;
    }

}
