<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

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
        return;
    }
%>
<div id="header-logo"><img src="/images/connexus_logo.png" /></div>
<ul id="header-navigation">
    <li> <a id="manage-tab" href="/manage.jsp">Manage</a></li>
    <li> <a id="create-tab" href="/create.jsp">Create</a></li>
    <li> <a id="view-tab" href="/view.jsp">View</a></li>
    <li> <a id="search-tab" href="/search.jsp">Search</a></li>
    <li> <a id="trending-tab" href="/trending.jsp">Trending</a></li>
    <li> <a id="social-tab" href="/social.jsp">Social</a></li>
    <li> <a href="<%= userService.createLogoutURL("/login.jsp") %>">Log out as <%= user.getNickname() %></a> </li>
</ul>
