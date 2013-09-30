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
          $("#trending-tab").addClass("current-tab");
          
          $("#update-rate-button").click(function(e) {
              e.preventDefault();
              console.log("update clicked");
              $.ajax({
                  type: "POST",
                  url: "/api/userProperty/update",
                  dataType: "json",
                  data: $("#trendUpdateRateForm").serialize()
              }).done(function(data) {
                  window.location = window.location;
              })
          })
          
          $.ajax({
              type: "GET",
              dataType: "json",
              url: "/api/stream/trending",
              success: function(data) {
                  console.log(data);
                  buildTrendingStreams(data.slice(0, 3), $('.gallery'))
              }
          })
          
          $.ajax({
        	  type: "GET",
        	  dataType: "json",
        	  url: "/api/userProperty/show?property=trendUpdateRate",
        	  beforeSend: function() {
        		  console.log("before getting userProperty...");
        	  },
        	  success: function(data) {
        		  console.log("success: " + data);
        		  if (data == "undefined") {
        			  var value = "no_reports";
        		  } else {
        			  var value = data.value;
        		  }
        		  console.log("value : " + value);
        		  $("input[value='" + value + "']").attr("checked", "checked");
        	  },
              error: function (xhr, ajaxOptions, thrownError) {
                console.log("error: " + xhr.responseText + thrownError + xhr);
                var value = "no_reports";
                $("input[value='" + value + "']").attr("checked", "checked");
              }
          });
      })
      </script>
    </jsp:attribute>
    <jsp:body>
        <div id="view-trending-streams">
            <h1>Top 3 Trending Streams</h1>
            <div class="gallery"></div>
            <form id="trendUpdateRateForm">
                <h1>Email trending report</h1>
                <input type="hidden" name="property" value="trendUpdateRate">
                <div class="report-frequency">
                    <input type="radio" name="value" value="no_reports"> No reports
                </div>
                <div class="report-frequency">
                    <input type="radio" name="value" value="5_min"> Every 5 minutes
                </div>
                <div class="report-frequency">
                    <input type="radio" name="value" value="1_hour"> Every 1 hour
                </div>
                <div class="report-frequency">
                    <input type="radio" name="value" value="1_day"> Every day
                </div>
                <div class="report-frequency button">
                    <input id="update-rate-button" type="submit" value="Update rate">
                </div>
            </form>
        </div>
    </jsp:body>
</t:wrapper>