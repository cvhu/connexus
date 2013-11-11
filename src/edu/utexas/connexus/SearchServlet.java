package edu.utexas.connexus;

import static com.googlecode.objectify.ObjectifyService.ofy;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.StringTokenizer;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.labs.repackaged.org.json.JSONArray;
import com.googlecode.objectify.ObjectifyService;


public class SearchServlet extends HttpServlet{
    static {
        ObjectifyService.register(SearchIndex.class);
        ObjectifyService.register(Stream.class);
        ObjectifyService.register(CImage.class);
    }
    static ExecutorService exec = Executors.newCachedThreadPool();
    
    private static final long serialVersionUID = 1L;

    public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        req.setCharacterEncoding("utf8");
        resp.setContentType("application/json");
        PrintWriter printWriter = resp.getWriter();
        
        String action = req.getPathInfo();
        if (action.startsWith("/rebuild")) {
            List<Stream> streams = ofy().load().type(Stream.class).list();
            for (Stream stream : streams) {
                SearchIndex.buildIndex(stream.getName(), stream.getId());
                SearchIndex.buildIndex(stream.getTags(), stream.getId());
            }
            List<CImage> images = ofy().load().type(CImage.class).list();
            for (CImage image : images) {
                String comment = image.getComment();
                SearchIndex.buildIndex(comment, image.getStreamId());
            }
            SearchIndex.updateIndices();
            printWriter.println("Success");
        } else if (action.equals("/indices")) {
            printWriter.println(SearchIndex.getIndices());
        } else if (action.equals("/cached")) {
            
        }
    }
}
