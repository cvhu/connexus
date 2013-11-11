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
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
		<!-- Bootstrap styles -->
		<link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.0.0/css/bootstrap.min.css">
		<!-- Generic page styles -->
		<link rel="stylesheet" href="stylesheets/style.css">
		<!-- blueimp Gallery styles -->
		<link rel="stylesheet" href="http://blueimp.github.io/Gallery/css/blueimp-gallery.min.css">
		<!-- CSS to style the file input field as button and adjust the Bootstrap progress bars -->
		<link rel="stylesheet" href="stylesheets/jquery.fileupload.css">
		<link rel="stylesheet" href="stylesheets/jquery.fileupload-ui.css">
		<!-- CSS adjustments for browsers with JavaScript disabled -->
		<noscript><link rel="stylesheet" href="css/jquery.fileupload-noscript.css"></noscript>
		<noscript><link rel="stylesheet" href="css/jquery.fileupload-ui-noscript.css"></noscript>
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
            
            
		    
            <!-- <form action="${uploadUrl}" method="post" enctype="multipart/form-data">
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
            </form> -->
        </div>
        
<form id="fileupload" action="${uploadUrl}" method="POST" enctype="multipart/form-data">
                <!-- Redirect browsers with JavaScript disabled to the origin page -->
                <!-- The fileupload-buttonbar contains buttons to add/delete files and start/cancel the upload -->
                <input type="hidden" name="stream-id" value="${id}">
                <input type="hidden" name="stream-name" />
                <div class="row fileupload-buttonbar">
                    <div class="col-lg-7">
                        <!-- The fileinput-button span is used to style the file input field as button -->
                        <span class="btn btn-success fileinput-button">
                            <i class="glyphicon glyphicon-plus"></i>
                            <span>Add files...</span>
                            <input type="file" name="files[]" multiple>
                        </span>
                        <button type="submit" class="btn btn-primary start">
                            <i class="glyphicon glyphicon-upload"></i>
                            <span>Start upload</span>
                        </button>
                        <button type="reset" class="btn btn-warning cancel">
                            <i class="glyphicon glyphicon-ban-circle"></i>
                            <span>Cancel upload</span>
                        </button>
                        <button type="button" class="btn btn-danger delete">
                            <i class="glyphicon glyphicon-trash"></i>
                            <span>Delete</span>
                        </button>
                        <input type="checkbox" class="toggle">
                        <!-- The global file processing state -->
                        <span class="fileupload-process"></span>
                    </div>
                    <!-- The global progress state -->
                    <div class="col-lg-5 fileupload-progress fade">
                        <!-- The global progress bar -->
                        <div class="progress progress-striped active" role="progressbar" aria-valuemin="0" aria-valuemax="100">
                            <div class="progress-bar progress-bar-success" style="width:0%;"></div>
                        </div>
                        <!-- The extended global progress state -->
                        <div class="progress-extended">&nbsp;</div>
                    </div>
                </div>
                <!-- The table listing the files available for upload/download -->
                <table role="presentation" class="table table-striped"><tbody class="files"></tbody></table>
            </form> 
            <!-- The blueimp Gallery widget -->
<div id="blueimp-gallery" class="blueimp-gallery blueimp-gallery-controls" data-filter=":even">
    <div class="slides"></div>
    <h3 class="title"></h3>
    <a class="prev">‹</a>
    <a class="next">›</a>
    <a class="close">×</a>
    <a class="play-pause"></a>
    <ol class="indicator"></ol>
</div>
<!-- The template to display files available for upload -->
<script id="template-upload" type="text/x-tmpl">
{% for (var i=0, file; file=o.files[i]; i++) { %}
    <tr class="template-upload fade">
        <td>
            <span class="preview"></span>
        </td>
        <td>
            <p class="name">{%=file.name%}</p>
            <strong class="error text-danger"></strong>
        </td>
        <td>
            <p class="size">Processing...</p>
            <div class="progress progress-striped active" role="progressbar" aria-valuemin="0" aria-valuemax="100" aria-valuenow="0"><div class="progress-bar progress-bar-success" style="width:0%;"></div></div>
        </td>
        <td>
            {% if (!i && !o.options.autoUpload) { %}
                <button class="btn btn-primary start" disabled>
                    <i class="glyphicon glyphicon-upload"></i>
                    <span>Start</span>
                </button>
            {% } %}
            {% if (!i) { %}
                <button class="btn btn-warning cancel">
                    <i class="glyphicon glyphicon-ban-circle"></i>
                    <span>Cancel</span>
                </button>
            {% } %}
        </td>
    </tr>
{% } %}
</script>
<!-- The template to display files available for download -->
<script id="template-download" type="text/x-tmpl">
{% for (var i=0, file; file=o.files[i]; i++) { %}
    <tr class="template-download fade">
        <td>
            <span class="preview">
                {% if (file.thumbnailUrl) { %}
                    <a href="{%=file.url%}" title="{%=file.name%}" download="{%=file.name%}" data-gallery><img src="{%=file.thumbnailUrl%}"></a>
                {% } %}
            </span>
        </td>
        <td>
            <p class="name">
                {% if (file.url) { %}
                    <a href="{%=file.url%}" title="{%=file.name%}" download="{%=file.name%}" {%=file.thumbnailUrl?'data-gallery':''%}>{%=file.name%}</a>
                {% } else { %}
                    <span>{%=file.name%}</span>
                {% } %}
            </p>
            {% if (file.error) { %}
                <div><span class="label label-danger">Error</span> {%=file.error%}</div>
            {% } %}
        </td>
        <td>
            <span class="size">{%=o.formatFileSize(file.size)%}</span>
        </td>
        <td>
            {% if (file.deleteUrl) { %}
                <button class="btn btn-danger delete" data-type="{%=file.deleteType%}" data-url="{%=file.deleteUrl%}"{% if (file.deleteWithCredentials) { %} data-xhr-fields='{"withCredentials":true}'{% } %}>
                    <i class="glyphicon glyphicon-trash"></i>
                    <span>Delete</span>
                </button>
                <input type="checkbox" name="delete" value="1" class="toggle">
            {% } else { %}
                <button class="btn btn-warning cancel">
                    <i class="glyphicon glyphicon-ban-circle"></i>
                    <span>Cancel</span>
                </button>
            {% } %}
        </td>
    </tr>
{% } %}
</script>

            <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
            <!-- The jQuery UI widget factory, can be omitted if jQuery UI is already included -->
            <script src="javascripts/jquery.ui.widget.js"></script>
            <!-- The Templates plugin is included to render the upload/download listings -->
            <script src="http://blueimp.github.io/JavaScript-Templates/js/tmpl.min.js"></script>
            <!-- The Load Image plugin is included for the preview images and image resizing functionality -->
            <script src="http://blueimp.github.io/JavaScript-Load-Image/js/load-image.min.js"></script>
            <!-- The Canvas to Blob plugin is included for image resizing functionality -->
            <script src="http://blueimp.github.io/JavaScript-Canvas-to-Blob/js/canvas-to-blob.min.js"></script>
            <!-- Bootstrap JS is not required, but included for the responsive demo navigation -->
            <script src="http://netdna.bootstrapcdn.com/bootstrap/3.0.0/js/bootstrap.min.js"></script>
            <!-- blueimp Gallery script -->
            <script src="http://blueimp.github.io/Gallery/js/jquery.blueimp-gallery.min.js"></script>
            <!-- The Iframe Transport is required for browsers without support for XHR file uploads -->
            <script src="javascripts/jquery.iframe-transport.js"></script>
            <!-- The basic File Upload plugin -->
            <script src="javascripts/jquery.fileupload.js"></script>
            <!-- The File Upload processing plugin -->
            <script src="javascripts/jquery.fileupload-process.js"></script>
            <!-- The File Upload image preview & resize plugin -->
            <script src="javascripts/jquery.fileupload-image.js"></script>
            <!-- The File Upload audio preview plugin -->
            <script src="javascripts/jquery.fileupload-audio.js"></script>
            <!-- The File Upload video preview plugin -->
            <script src="javascripts/jquery.fileupload-video.js"></script>
            <!-- The File Upload validation plugin -->
            <script src="javascripts/jquery.fileupload-validate.js"></script>
            <!-- The File Upload user interface plugin -->
            <script src="javascripts/jquery.fileupload-ui.js"></script>
            <!-- The main application script -->
            <script type="text/javascript">
            $(function() {
            	$('#fileupload').fileupload({
            		xhrFields: {withCredentials: true},
            		url: $('#fileupload').attr('action'),
            		always: function() {
            			console.log("uploaded");
            			//location.reload();
            		},
            		chunkalways: function() {
            			console.log("chunkalways");
            		},
            		stop: function() {
            			console.log("stop");
            			location.reload();
            		},
            		fail: function(e, data) {
            			console.log("failed\n error:" + data.errorThrown + "\n textStatus:" + data.textStatus);
            		}
            	});
            });
            </script>
    </jsp:body>
</t:wrapper>

