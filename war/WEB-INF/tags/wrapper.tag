<%@tag description="Wrapper template" pageEncoding="UTF-8"%>
<%@attribute name="head" fragment="true" %>
<%@attribute name="title" fragment="true" %>
<html>
<title>Connexus <jsp:invoke fragment="title"/></title>
    <head>
        <link rel="stylesheet" href="/stylesheets/Connexus.css" />
        <link rel="stylesheet" href="/stylesheets/font-awesome/css/font-awesome.min.css" />
        <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
        <script src="/javascripts/Connexus.js"></script>
        <jsp:invoke fragment="head"/>
    </head>
    <body>
        <div id="wrapper">
	        <div id="pageheader">
	           <jsp:include page="pageHeader.jsp" />
	        </div>
	        <div id="body">
	            <jsp:doBody/>
	        </div>
	        <div id="pagefooter">
	            Connexus 2013
	        </div>
	    </div>
  </body>
</html>