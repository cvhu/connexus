<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.google.appengine.api.users.User" %>
<%@ page import="com.google.appengine.api.users.UserService" %>
<%@ page import="com.google.appengine.api.users.UserServiceFactory" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<html>
    <title>Connexus</title>
    <head>
        <link rel="stylesheet" href="/stylesheets/Connexus.css" />
        <link rel="stylesheet" href="/stylesheets/font-awesome/css/font-awesome.min.css" />
        <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
    </head>
    <script>
    $(document).ready(function() {
        $("#title").hide().fadeIn();
    })
    </script>
    <body>
       <%
           UserService userService = UserServiceFactory.getUserService();
           User user = userService.getCurrentUser();
           if (user != null) {
               pageContext.setAttribute("user", user);
               response.sendRedirect(String.format("/manage.jsp", user.getUserId()));
           }
       %>
        <div id="login-wrapper">
            <div id="logo"><img src="/images/connexus_logo.png" /></div>
            <div id="login-button">
                <a class="btn login-button" href="<%= userService.createLoginURL(request.getRequestURI()) %>">
                <i class="icon-google-plus icon-2x"></i> <span>Log in with Google</span>
            </a>
            </div>
            
        </div>
    </body>
</html>