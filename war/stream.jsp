<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="t" tagdir="/WEB-INF/tags" %>

<%@ page import="com.google.appengine.api.blobstore.BlobstoreService" %>
<%@ page import="com.google.appengine.api.blobstore.BlobstoreServiceFactory" %>

<% request.setAttribute("id", request.getParameter("id")); %>
<% request.setAttribute("uploadUrl", BlobstoreServiceFactory.getBlobstoreService().createUploadUrl("/api/image")); %>
<t:wrapper>
    <jsp:attribute name="head">
      <script>
      $(document).ready(function() {
          $("#view-tab").addClass("current-tab");
          
          $.ajax({
        	  type: "GET",
        	  url: "/api/subscription/exists?stream_id=" + $("#id").text(),
        	  success: function(data) {
        		  console.log(data);
        		  if (data==true) {
        			  $('#stream-subscribe').html("Subscribed").attr("href", null);
        		  } else {
        			  $("#stream-subscribe").click(function(e) {
        	              e.preventDefault();
        	              $(this).html("Subscribed");
        	              $.ajax({
        	                  type: "POST",
        	                  url: "/api/subscription",
        	                  data: {
        	                      stream_id: $("#id").text()
        	                   },
        	                  dataType: "json",
        	                  success: function(data) {
        	                      window.location = window.location;
        	                  }
        	              })
        	          });
        		  }
        	  }
          })
          
          $.ajax({
        	  type: "GET",
        	  url: "/api/stream/show?id="+$("#id").text(),
        	  success: function(data) {
        		  $(".name").html(data.name);
        		  $(".tags").html(data.tags);
        		  $(".views").html(data.views + " views");
        		  $(".created-by").html("by " + data.userNickname);
        		  $(".created-on").html(data.createdOn);
        		  $(".cover-image").attr("src", data.coverUrl);
        		  $("input[name='stream-name']").val(data.name);
        	  }
          })
          
          
          
          $.ajax({
        	  type: "GET",
        	  dataType: "json",
        	  url: "/api/image/by_stream?stream-id=" + $("#id").text(),
        	  success: function(data) {
        		  console.log(data);
        		  $("<a href='#' id='load-more'></a>").html("Load More").insertAfter(".gallery").click(function(e) {
        			  e.preventDefault();
        			  loadMoreImages(data, 3);
        		  })
        		  loadMoreImages(data, 3);
        	  }
          })
          
          
      })
      
      function loadMoreImages(data, n) {
    	  if (data.length < n) {
    		  n = data.length;
    		  $("#load-more").fadeOut();
    	  }
    	  for (var ind = 0; ind < n; ind++) {
              console.log(data[0].bkUrl);
              var img_div = $('<div class="image"></div>').appendTo($('.gallery'));
              $("<img>").attr("src", data[0].bkUrl).appendTo(img_div);
              var comments_wrapper = $('<div class="comments-wrapper"></div>').appendTo(img_div);
              $('<div class="comments"></div>').html(data[0].comments).appendTo(comments_wrapper);
              $('<div class="username"></div>').html("by <b>" + data[0].userNickname + "</b>").appendTo(comments_wrapper);
              $('<div class="created-on"></div>').html(data[0].createdOn).appendTo(comments_wrapper);
              data.splice(0, 1);
          }
      }
      
      function postImage(data) {
    	  $.ajax({
    		  type: "POST",
    		  url: data,
    		  data: $("form").serialize(),
    		  success: function(data) {
    			  alert(data);
    		  }
    	  })
      }
      </script>
    </jsp:attribute>
    <jsp:body>
        <div id="id" style="display:none;">${id}</div>
        <div id="stream-view">
            <div class="cover">
                <img class="cover-image">
                <div class="name">
                </div>
            </div>
            <div class="description-panel">
                <div class="created-by"></div>
                <div class="created-on"></div>
                <div class="tags"></div>
                <div class="views"></div>
            </div>
            <a id="stream-subscribe" href="#">Subscribe</a>
            <div class="gallery">
            </div>
            <form action="${uploadUrl}" method="post" enctype="multipart/form-data">
                <h1> Add an Image</h1>
                <div class="form-field">
                    <label>File</label>
                    <input name="filename" type="file" placeholder="filename">
                </div>
                <div class="form-field">
                    <label>Comments</label>
                    <input name="comments" type="text" placeholder="comments">
                </div>
                <input type="hidden" name="stream-id" value="${id}">
                <input type="hidden" name="stream-name" />
                <div class="form-field">
                    <input id="post-image-button" type="submit" value="Upload file" />
                </div>
            </form>
        </div>
    </jsp:body>
</t:wrapper>

