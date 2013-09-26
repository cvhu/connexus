<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="t" tagdir="/WEB-INF/tags" %>

<t:wrapper>
    <jsp:attribute name="head">
      <script>
      $(document).ready(function() {
          $("#trending-tab").addClass("current-tab");
      })
      </script>
    </jsp:attribute>
    <jsp:body>
        <p>manage</p>
    </jsp:body>
</t:wrapper>