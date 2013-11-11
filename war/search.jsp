<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="t" tagdir="/WEB-INF/tags" %>

<t:wrapper>
    <jsp:attribute name="head">
    <script src="http://code.jquery.com/ui/1.10.3/jquery-ui.js"></script>
    <link rel="stylesheet" href="http://code.jquery.com/ui/1.10.3/themes/smoothness/jquery-ui.css" />
      <script>
      $(document).ready(function() {
          $("#search-tab").addClass("current-tab");
          $("#search-button").click(function(e) {
        	  e.preventDefault();
        	  search($("input[name='query']").val());
          })
          $.ajax({
               type: "GET",
               dataType: "json",
               url: "/api/search/indices",
               success: function(data) {
                   console.log(data);
                   
                   $("input[name='query']").autocomplete({
                       source: data,
                       select: function( event, ui) {
                    	   console.log(ui.item.value);
                    	   search(ui.item.label);
                       }
                   })
               }
           })
           
           $("#rebuild-index").click(function(e) {
        	   e.preventDefault();
        	   $("#rebuild-status").hide().text("Rebuilt success.").fadeIn();
        	   $.ajax({
        		   type: "GET",
        		   url: "/api/search/rebuild",
        		   success: function(data) {
        		   }
        	   });
           })
      })
      
      function search(query) {
    	  $(".gallery").empty();
          $.ajax({
              type: "GET",
              dataType: "json",
              url: "/api/stream/search?query=" + query,
              success: function(data) {
                  console.log(data);
                  $(".description").html(data.length + " results for <b>" + query + "</b>, click on an image to view stream.")
                  buildStreamResults(data, $('.gallery'))
              }
          })
      }
      </script>
    </jsp:attribute>
    <jsp:body>
        <div id="search-wrapper">
            <form action="/api/stream/search" method="post">
                <input type="text" name="query" placeholder="Lucknow">
                <input id="search-button" type="submit" value="Search">
                    <a href="#" id="rebuild-index">Rebuild completion index</a>
                    <span id="rebuild-status" style="color: #0af;"></span>
            </form>
            <div class="description"></div>
            <div class="gallery"></div>
        </div>
    </jsp:body>
</t:wrapper>