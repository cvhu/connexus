package edu.utexas.connexus;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Collections;
import java.util.List;
import java.util.Iterator;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.blobstore.BlobKey;
import com.google.appengine.api.blobstore.BlobstoreService;
import com.google.appengine.api.blobstore.BlobstoreServiceFactory;
import com.google.appengine.api.images.ImagesService;
import com.google.appengine.api.images.ImagesServiceFactory;
import com.google.appengine.api.users.User;
import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;
import com.google.appengine.labs.repackaged.org.json.JSONArray;
import com.google.appengine.labs.repackaged.org.json.JSONObject;
import com.googlecode.objectify.Objectify;
import com.googlecode.objectify.ObjectifyService;

import static com.googlecode.objectify.ObjectifyService.ofy;

public class CImageServlet extends HttpServlet {
    static {
        ObjectifyService.register(CImage.class);
    }
    static ExecutorService exec = Executors.newCachedThreadPool();
    
    private static final long serialVersionUID = 1L;
    private BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();
    
    @Override
    public void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        
        Map<String, BlobKey> blobs = blobstoreService.getUploadedBlobs(req);
        BlobKey blobKey = blobs.get("files[]");
        ImagesService imagesService = ImagesServiceFactory.getImagesService();
        String bkUrl = imagesService.getServingUrl(blobKey);
        
        UserService userService = UserServiceFactory.getUserService();
        User user = userService.getCurrentUser();
        
        req.setCharacterEncoding("utf8");

        String streamId = req.getParameter("stream-id");
        String streamName = req.getParameter("stream-name");
        String comments = req.getParameter("comments");
        
        CImage cimage = new CImage(user, streamId, streamName, comments, bkUrl);
        
        ofy().save().entity(cimage).now();
        
        PrintWriter printWriter = resp.getWriter();
        printWriter.println(cimage.uploaderToString());
        resp.sendRedirect("/stream.jsp?id=" + streamId);
    }
    
    @Override 
    public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter printWriter = resp.getWriter();
        String action = req.getPathInfo();
        if (action.equals("/upload_url")) {
            printWriter.println(blobstoreService.createUploadUrl("/api/image"));
        } else if (action.equals("/show")) {
            CImage cimage = ofy().load().type(CImage.class).id(new Long(req.getParameter("id"))).get();
            printWriter.println(cimage.getJSON());
        } else if (action.equals("/by_stream")) {
            List<CImage> cimages = ofy().load().type(CImage.class).list();
            Collections.sort(cimages);
            Collections.reverse(cimages);
            String streamId = req.getParameter("stream-id");
            for (Iterator<CImage> it = cimages.iterator(); it.hasNext();) {
                CImage cimage= it.next();
                if ((cimage.streamId == null) || !cimage.streamId.equals(streamId)) {
                    it.remove();
                }
            }
            printWriter.println(cimages.toString());
        } else {
            List<CImage> cimages = ofy().load().type(CImage.class).list();
            Collections.sort(cimages);
            Collections.reverse(cimages);
            printWriter.println(cimages.toString());
        }
    }
  
}
