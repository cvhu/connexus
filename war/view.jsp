<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="t" tagdir="/WEB-INF/tags" %>

<t:wrapper>
    <jsp:attribute name="head">
      <script>
      $(document).ready(function() {
          $("#view-tab").addClass("current-tab");
          
          $.ajax({
              type: "GET",
              dataType: "json",
              url: "/api/stream/all",
              success: function(data) {
                  console.log(data);
                  buildStreams(data, $('.gallery'))
              }
          })
      })
      </script>
    </jsp:attribute>
    <jsp:body>
        <div id="view-all-streams">
            <h1>View All Streams</h1>
            <div class="gallery"></div>
        </div>
    </jsp:body>
</t:wrapper>