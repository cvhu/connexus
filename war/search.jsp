<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="t" tagdir="/WEB-INF/tags" %>

<t:wrapper>
    <jsp:attribute name="head">
      <script>
      $(document).ready(function() {
          $("#search-tab").addClass("current-tab");
          $("#search-button").click(function(e) {
        	  e.preventDefault();
        	  $(".gallery").empty();
        	  var query = $("input[name='query']").val();
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
          })
      })
      </script>
    </jsp:attribute>
    <jsp:body>
        <div id="search-wrapper">
            <form action="/api/stream/search" method="post">
                <input type="text" name="query" placeholder="Lucknow">
                <input id="search-button" type="submit" value="Search">
            </form>
            <div class="description"></div>
            <div class="gallery"></div>
        </div>
    </jsp:body>
</t:wrapper>