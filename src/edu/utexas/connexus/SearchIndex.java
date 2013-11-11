package edu.utexas.connexus;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.StringTokenizer;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import com.google.appengine.labs.repackaged.org.json.JSONException;
import com.google.appengine.labs.repackaged.org.json.JSONObject;
import com.googlecode.objectify.ObjectifyService;
import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Id;

import static com.googlecode.objectify.ObjectifyService.ofy;

@Entity
public class SearchIndex implements Comparable<SearchIndex> {
    static {
        ObjectifyService.register(SearchIndex.class);
    }
    
    static ExecutorService exec = Executors.newCachedThreadPool();
    @Id Long id;
    String key;
    Date createdOn;
    List<String> streamIds = new ArrayList<String>();
    private static final HashMap<String, SearchIndex> indexMap = new HashMap<String, SearchIndex>();
    
    private SearchIndex() {}
    
    public SearchIndex(String key) {
        this.key = key;
        this.createdOn = new Date();
    }
    
    public static List<String> search(String key) {
        List<SearchIndex> indices = ofy().load().type(SearchIndex.class).list();
        for (SearchIndex index : indices) {
            if (index.getKey().equals(key)) {
                return index.getStreamIds();
            }
        }
        return null;
    }
    
    public static void buildIndex(String text, String streamId) {
        String processedText = text.toLowerCase().replaceAll("[^a-z0-9]", " ");
        StringTokenizer tokenizer = new StringTokenizer(processedText);
        while (tokenizer.hasMoreTokens()) {
            String key = tokenizer.nextToken().trim();
            System.out.println("Indexing " + key);
            SearchIndex index = indexMap.get(key);
            if (index == null) {
                index = new SearchIndex(key);
            }
            index.addStreamId(streamId);
            indexMap.put(key, index);
        }
    }
    
    public static void updateIndices() {
        List<SearchIndex> indices = ofy().load().type(SearchIndex.class).list();
        for (String key : indexMap.keySet()) {
            boolean isNewIndex = true;
            SearchIndex newIndex = indexMap.get(key);
            System.out.printf("Index[%s] = %s\n", key, Arrays.asList(newIndex.getStreamIds()));
            for (SearchIndex oldIndex : indices) {
                if (oldIndex.getKey().equals(key)) {
                    oldIndex.setStreamIds(newIndex.getStreamIds());
                    ofy().save().entity(oldIndex).now();
                    isNewIndex = false;
                    break;
                }
            }
            if (isNewIndex) {
                ofy().save().entity(newIndex).now();
            }
        }
    }
    
    public static List<SearchIndex> getIndices() {
        return ofy().load().type(SearchIndex.class).list();
    }
    
    public void setStreamIds(List<String> streamIds) {
        this.streamIds = streamIds;
    }
    
    public List<String> getStreamIds() {
        return streamIds;
    }
    
    public void addStreamId(String streamId) {
        if (!streamIds.contains(streamId)) {
            streamIds.add(streamId);
        }
    }
    
    public JSONObject getJSON() {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put("id", id);
            jsonObject.put("label", key);
            jsonObject.put("streamIds", streamIds);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return jsonObject;
    }
    
    public String toString() {
        return getJSON().toString();
    }
    
    public String getKey() {
        return key;
    }
    
    @Override
    public int compareTo(SearchIndex other) {
        return String.CASE_INSENSITIVE_ORDER.compare(getKey(), other.getKey());
    }
}
