package edu.utexas.connexus;

import com.google.appengine.api.users.User;
import com.google.appengine.labs.repackaged.org.json.JSONException;
import com.google.appengine.labs.repackaged.org.json.JSONObject;
import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Id;

@Entity
public class UserProperty{
    @Id Long id;
    User user;
    String property;
    String value;
    
    private UserProperty() {}
    
    public UserProperty(User user, String property, String value) {
        this.user = user;
        this.property = property;
        this.value = value;
    }
    
    public User getUser() {
        return user;
    }
    
    public String getUserEmail() {
        return user.getEmail();
    }
    
    public JSONObject getJSON() {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put("id", id);
            jsonObject.put("userNickname", getUsername());
            jsonObject.put("property", property);
            jsonObject.put("value", value);
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
    
    public void setValue(String v) {
        value = v;
    }
    
    public String getValue() {
        return value;
    }
    
    public boolean isProperty(User u, String p) {
        return user.equals(u) && property.equals(p);
    }
    
    public String getProperty() {
        return property;
    }
    
    @Override
    public String toString() {
        return getJSON().toString();
    }
}
