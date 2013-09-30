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
    	  $("#error-message").empty().hide();
          $("#create-tab").addClass("current-tab");
          $("#post-stream-button").click(function(e) {
        	  e.preventDefault();
        	  postStream();
          })
      })
      
      function postStream() {
    	  $.ajax({
    		  type: "POST",
    		  url: "/api/stream/add",
    		  data: $("#create-page form").serialize(),
    		  success: function(data) {
    			  window.location = "/stream.jsp?id="+data.id;
    		  },
              error: function (xhr, ajaxOptions, thrownError) {
                console.log("error: " + xhr.responseText + thrownError + xhr);
                $("#error-message").html(xhr.responseText).fadeIn();
              }
    	  })
      }
      </script>
    </jsp:attribute>
    <jsp:body>
        <div id="create-page" class="tab-wrapper">
            <form>
                <div class="form-field">
                    <label>Name your stream</label>
                    <input name="name" type="text" placeholder="Lucknow Christian College"/>
                </div>
                <div class="form-field">
                    <label>Tag your stream</label>
                    <textarea name="tags" placeholder="#1985, #LucknowChristianCollege, #FB:schools.india.LCC"></textarea>
                </div>
                <div class="form-field">
                    <label>URL to cover image (optional)</label>
                    <input name="cover" type="text" placeholder="http://flickr.com/tiger-image.png"/>
                </div>
                <div class="form-field">
                    <label>Add subscribers</label>
                    <textarea name="subscriber-emails" placeholder="adnan@aziz.com, alephone@facebook.com"></textarea>
                    <textarea name="subscriber-message" placeholder="Optional message for invite"></textarea>
                </div>
                <div class="form-field">
                    <div style="display:none;" id="error-message"></div>
                    <input type="submit" id="post-stream-button" value="Create Stream" />
                </div>
            </form>
        </div>
    </jsp:body>
</t:wrapper>