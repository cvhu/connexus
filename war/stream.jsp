<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="t" tagdir="/WEB-INF/tags" %>


<%@ page import="com.google.appengine.api.users.User" %>
<%@ page import="com.google.appengine.api.users.UserService" %>
<%@ page import="com.google.appengine.api.users.UserServiceFactory" %>

<%
    UserService userService = UserServiceFactory.getUserService();
    User user = userService.getCurrentUser();
    if (user == null) {
        response.sendRedirect("/login.jsp");
        System.out.println("no user");
        pageContext.setAttribute("user", null);
    }
%>


<%@ page import="com.google.appengine.api.blobstore.BlobstoreService" %>
<%@ page import="com.google.appengine.api.blobstore.BlobstoreServiceFactory" %>

<% request.setAttribute("id", request.getParameter("id")); %>
<% request.setAttribute("uploadUrl", BlobstoreServiceFactory.getBlobstoreService().createUploadUrl("/api/image")); %>
<t:wrapper>
    <jsp:attribute name="head">
      <script>
      $(document).ready(function() {
          $("#view-tab").addClass("current-tab");
          
          $.ajax({
        	  type: "GET",
        	  url: "/api/subscription/exists?stream_id=" + $("#id").text(),
        	  success: function(data) {
        		  console.log(data);
        		  if (data==true) {
        			  $('#stream-subscribe').html("Subscribed").attr("href", null);
        		  } else {
        			  $("#stream-subscribe").click(function(e) {
        	              e.preventDefault();
        	              $(this).html("Subscribed");
        	              $.ajax({
        	                  type: "POST",
        	                  url: "/api/subscription/add",
        	                  data: {
        	                      stream_id: $("#id").text()
        	                   },
        	                  dataType: "json",
        	                  success: function(data) {
        	                      window.location = window.location;
        	                  }
        	              })
        	          });
        		  }
        	  }
          })
          
          $.ajax({
        	  type: "GET",
        	  url: "/api/stream/show?id="+$("#id").text(),
        	  success: function(data) {
        		  $(".name").html(data.name);
        		  $(".tags").html(data.tags);
        		  $(".views").html(data.views + " views");
        		  $(".created-by").html("by " + data.userNickname);
        		  $(".created-on").html(data.createdOn);
        		  $(".cover-image").attr("src", data.coverUrl);
        		  $("input[name='stream-name']").val(data.name);
        	  }
          })
          
          
          
          $.ajax({
        	  type: "GET",
        	  dataType: "json",
        	  url: "/api/image/by_stream?stream-id=" + $("#id").text(),
        	  success: function(data) {
        		  console.log(data);
        		  $("<a href='#' id='load-more'></a>").html("Load More").insertAfter(".gallery").click(function(e) {
        			  e.preventDefault();
        			  loadMoreImages(data, 3);
        		  })
        		  loadMoreImages(data, 3);
        	  }
          })
          
          
      })
      
      function loadMoreImages(data, n) {
    	  if (data.length < n) {
    		  n = data.length;
    		  $("#load-more").fadeOut();
    	  }
    	  for (var ind = 0; ind < n; ind++) {
              console.log(data[0].bkUrl);
              var img_div = $('<div class="image"></div>').appendTo($('.gallery'));
              $("<img>").attr("src", data[0].bkUrl).appendTo(img_div);
              var comments_wrapper = $('<div class="comments-wrapper"></div>').appendTo(img_div);
              $('<div class="comments"></div>').html(data[0].comments).appendTo(comments_wrapper);
              $('<div class="username"></div>').html("by <b>" + data[0].userNickname + "</b>").appendTo(comments_wrapper);
              $('<div class="created-on"></div>').html(data[0].createdOn).appendTo(comments_wrapper);
              data.splice(0, 1);
          }
      }
      </script>
    </jsp:attribute>
    <jsp:body>
        <div id="fb-root"></div>
        <script>
        window.fbAsyncInit = function() {
            FB.init({
                appId      : '516844101738737', // App ID
                channelUrl : '//conn3xus.appspot.com/channel.html', // Channel File
                status     : true, // check login status
                cookie     : true, // enable cookies to allow the server to access the session
                xfbml      : true  // parse XFBML
            });

            
         // Here we subscribe to the auth.authResponseChange JavaScript event. This event is fired
            // for any authentication related change, such as login, logout or session refresh. This means that
            // whenever someone who was previously logged out tries to log in again, the correct case below 
            // will be handled. 
            FB.Event.subscribe('auth.authResponseChange', function(response) {
              // Here we specify what we do with the response anytime this event occurs. 
              if (response.status === 'connected') {
                // The response object is returned with a status field that lets the app know the current
                // login status of the person. In this case, we're handling the situation where they 
                // have logged in to the app. 
              } else if (response.status === 'not_authorized') {
                // In this case, the person is logged into Facebook, but not into the app, so we call
                // FB.login() to prompt them to do so. 
                // In real-life usage, you wouldn't want to immediately prompt someone to login 
                // like this, for two reasons:
                // (1) JavaScript created popup windows are blocked by most browsers unless they 
                // result from direct interaction from people using the app (such as a mouse click)
                // (2) it is a bad experience to be continually prompted to login upon page load.
                $("#stream-share").attr("href", null);
              } else {
                // In this case, the person is not logged into Facebook, so we call the login() 
                // function to prompt them to do so. Note that at this stage there is no indication
                // of whether they are logged into the app. If they aren't then they'll see the Login
                // dialog right after they log in to Facebook. 
                // The same caveats as above apply to the FB.login() call here.
                  $("#stream-share").attr("href", null);
              }
            });

        };
        
     // Load the SDK asynchronously
        (function(d){
            var js, id = 'facebook-jssdk', ref = d.getElementsByTagName('script')[0];
            if (d.getElementById(id)) {return;}
            js = d.createElement('script'); js.id = id; js.async = true;
            js.src = "//connect.facebook.net/en_US/all.js";
            ref.parentNode.insertBefore(js, ref);
        }(document));
        
        function shareStream() {
        	FB.ui(
                    {
                         method: 'feed',
                         name: 'Connexus Stream: ' + $(".name").html(),
                         caption: 'Create, view, and share photos in the Connexus fashion',
                         description: (
                            'tags: ' + $(".tags").html() + 
                            ' ' + $(".created-by").html() + 
                            ' ' + $(".views").html()
                         ),
                         link: 'http://conn3xus.appspot.com/stream.jsp?id=' + $("#id").html(),
                         picture: $(".cover-image").attr("src")
                        },
                        function(response) {
                          if (response && response.post_id) {
                            alert('Post was published.');
                          } else {
                            alert('Post was not published.');
                          }
                        }
                      );
        }
        </script>
        <div id="id" style="display:none;">${id}</div>
        <div id="stream-view">
            <div class="cover">
                <img class="cover-image">
                <div class="name">
                </div>
            </div>
            <div class="description-panel">
                <div class="created-by"></div>
                <div class="created-on"></div>
                <div class="tags"></div>
                <div class="views"></div>
            </div>
            <a id="stream-subscribe" href="#">Subscribe</a>
            <a id="stream-share" href="#" onclick="shareStream();">Share</a>
            <div class="gallery">
            </div>
            <form action="${uploadUrl}" method="post" enctype="multipart/form-data">
                <h1> Add an Image</h1>
                <div class="form-field">
                    <label>File</label>
                    <input name="filename" type="file" placeholder="filename">
                </div>
                <div class="form-field">
                    <label>Comments</label>
                    <input name="comments" type="text" placeholder="comments">
                </div>
                <input type="hidden" name="stream-id" value="${id}">
                <input type="hidden" name="stream-name" />
                <div class="form-field">
                    <input id="post-image-button" type="submit" value="Upload file" />
                </div>
            </form>
        </div>
    </jsp:body>
</t:wrapper>

