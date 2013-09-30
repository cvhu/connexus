<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="t" tagdir="/WEB-INF/tags" %>

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


<t:wrapper>
    <jsp:attribute name="head">
      <script>
          $(document).ready(function() {
        	  $("#manage-tab").addClass("current-tab");
        	  
        	  $.ajax({
        		  type: "GET",
        		  dataType: "json",
        		  url: "/api/stream/mine",
        		  success: function(data) {
        			  console.log(data);
        			  var wrapper = $("<form action='/api/stream/delete' id='my-streams'></form>").appendTo($("#manage-page"));
        			  $("<h1></h1>").html("My Streams").appendTo(wrapper);
        			  buildMineTitle(wrapper);
        			  buildStreamManagement(data, wrapper);
        			  loadSubscriptions();
        			  var button = $("<div class='submit'><input id='delete-streams-button' type='submit'></div>").appendTo(wrapper);
        			  $(button).click(function(e) {
        				  e.preventDefault();
        				  submitForm(wrapper);
        			  })
        		  }
        	  });
        	  
          })
          
          function loadSubscriptions() {
              $.ajax({
                  type: "GET",
                  dataType: "json",
                  url: "/api/subscription/show",
                  success: function(data) {
                      console.log(data);
                      var wrapper = $("<form action='/api/subscription/delete' id='my-subscriptions'></form>").appendTo($("#manage-page"));
                      $("<h1></h1>").html("My Subscriptions").appendTo(wrapper);
                      buildSubscribeTitle(wrapper);
                      buildStreamManagement(data, wrapper);
                      var button = $("<div class='submit'><input id='unsubscribe-button' type='submit'></div>").appendTo(wrapper);
                      $(button).click(function(e) {
                          e.preventDefault();
                          submitForm(wrapper);
                      })
                  }
              });
          }
          
          function submitForm(form) {
        	  console.log($(form).attr("action"));
        	  console.log($(form).serialize());
        	  $.ajax({
        		  type: "POST",
        		  url: $(form).attr("action"),
        		  data: $(form).serialize(),
        		  dataType: "json",
        		  beforeSend: function() {
        			  console.log("before send");
        		  },
        		  success: function(data) {
        			  console.log("data: " + data);
        			  window.location = window.location;
        		  },
        		  error: function(e) {
        			  console.log("error: " + e);
        			  window.location = window.location;
        		  }
        	  })
          }
          
          function buildMineTitle(wrapper) {
        	  var title = $("<div class='title manage-stream'></div>").appendTo(wrapper);
              $('<div class="name"></div>').html("Stream Name").appendTo(title);
              $('<div class="view-count"></div>').html("Views").appendTo(title);
              $('<div class="image-count"></div>').html("Images").appendTo(title);
              $('<div class="last-image"></div>').html("Last Image").appendTo(title);
              $('<div class="check-box"></div>').html("Delete").appendTo(title);
          }
          
          function buildSubscribeTitle(wrapper) {
              var title = $("<div class='title manage-stream'></div>").appendTo(wrapper);
              $('<div class="name"></div>').html("Stream Name").appendTo(title);
              $('<div class="view-count"></div>').html("Views").appendTo(title);
              $('<div class="image-count"></div>').html("Images").appendTo(title);
              $('<div class="last-image"></div>').html("Last Image").appendTo(title);
              $('<div class="check-box"></div>').html("Unsubscribe").appendTo(title);
          }
          
          function buildStreamManagement(data, wrapper) {
        	  for (var ind = 0; ind < data.length; ind++) {
        		  var stream = data[ind];
        		  if (stream.name.length == 0) {
        			  stream.name = "empty";
        		  }
        		  console.log(stream);
                  var div = $("<div class='manage-stream manage-stream-row'></div>").appendTo(wrapper);
                  $("<a class='name'></a>").attr('href', '/stream.jsp?id=' + stream.id).html(stream.name).appendTo(div);
                  $('<div class="view-count"></div>').html(stream.views).appendTo(div);
                  buildImageStats(stream.id, div);
        	  }
          }
          
          function buildImageStats(streamId, wrapper) {
        	  $.ajax({
        		  type: "GET",
        		  dataType: "json",
        		  url: "/api/image/by_stream?stream-id=" + streamId,
        		  success: function(data) {
        			  if (data == 0) {
        				  var createdOn = "no images";
        				  var imageCount = 0;
        			  } else {
        				  var createdOn = data[0].createdOn;
        				  var imageCount = data.length;
        			  }
        			  $("<div class='image-count'></div>").html(imageCount).appendTo(wrapper);
        			  $("<div class='last-image'></div>").html(createdOn).appendTo(wrapper);
        			  $("<div class='check-box'></div>").html("<input type=checkbox name=stream_id value=" + streamId + ">").appendTo(wrapper);
        		  }
        	  })
          }
      </script>
    </jsp:attribute>
    <jsp:body>
        <div id="manage-page">
        </div>
    </jsp:body>
</t:wrapper>