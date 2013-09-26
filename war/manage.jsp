<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="t" tagdir="/WEB-INF/tags" %>

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
        			  var wrapper = $("<form id='my-streams'></form>").appendTo($("#manage-page"));
        			  buildMineTitle(wrapper);
        			  buildStreamManagement(data, wrapper);
        		  }
        	  });
          })
          
          function buildMineTitle(wrapper) {
        	  var title = $("<div class='title'></div>").appendTo(wrapper);
              $('<div class="name"></div>').html("Stream Name").appendTo(title);
              $('<div class="view-count"></div>').html("View Count").appendTo(title);
              $('<div class="last-image"></div>').html("Last Image").appendTo(title);
              $('<div class="image-count"></div>').html("Images Count").appendTo(title);
              $('<div class="check-box"></div>').html("Delete").appendTo(title);
          }
          
          function buildStreamManagement(data, wrapper) {
        	  for (var ind = 0; ind < data.length; ind++) {
        		  var stream = data[ind];
        		  console.log(stream);
        		  var div = $("<div class='manage-stream'></div>").appendTo(wrapper);
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
        			  $("<div class='last-image'></div>").html(createdOn).appendTo(wrapper);
        			  $("<div class='image-count'></div>").html(imageCount).appendTo(wrapper);
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