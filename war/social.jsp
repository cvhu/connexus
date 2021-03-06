<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="t" tagdir="/WEB-INF/tags" %>

<t:wrapper>
    <jsp:attribute name="head">
      <script>
      $(document).ready(function() {
          $("#social-tab").addClass("current-tab");
      })
      </script>
    </jsp:attribute>
    <jsp:body>
        <div id="fb-root"></div>
        <script>
            // Additional JS functions here
            window.fbAsyncInit = function() {
                FB.init({
                    appId      : '516844101738737', // App ID
                    channelUrl : '//conn3xus.appspot.com/channel.html', // Channel File
                    status     : true, // check login status
                    cookie     : true, // enable cookies to allow the server to access the session
                    xfbml      : true  // parse XFBML
                });
                
             // Here we subscribe to the auth.authResponseChange JavaScript event. This event is fired
                // for any authentication related change, such as login, logout or session refresh. This means that
                // whenever someone who was previously logged out tries to log in again, the correct case below 
                // will be handled. 
                FB.Event.subscribe('auth.authResponseChange', function(response) {
                  // Here we specify what we do with the response anytime this event occurs. 
                  if (response.status === 'connected') {
                    // The response object is returned with a status field that lets the app know the current
                    // login status of the person. In this case, we're handling the situation where they 
                    // have logged in to the app. 
                    update_fb_api(response);
                  } else if (response.status === 'not_authorized') {
                    // In this case, the person is logged into Facebook, but not into the app, so we call
                    // FB.login() to prompt them to do so. 
                    // In real-life usage, you wouldn't want to immediately prompt someone to login 
                    // like this, for two reasons:
                    // (1) JavaScript created popup windows are blocked by most browsers unless they 
                    // result from direct interaction from people using the app (such as a mouse click)
                    // (2) it is a bad experience to be continually prompted to login upon page load.
                    FB.login();
                  } else {
                    // In this case, the person is not logged into Facebook, so we call the login() 
                    // function to prompt them to do so. Note that at this stage there is no indication
                    // of whether they are logged into the app. If they aren't then they'll see the Login
                    // dialog right after they log in to Facebook. 
                    // The same caveats as above apply to the FB.login() call here.
                    FB.login();
                  }
                });

            };

            // Load the SDK asynchronously
            (function(d){
                var js, id = 'facebook-jssdk', ref = d.getElementsByTagName('script')[0];
                if (d.getElementById(id)) {return;}
                js = d.createElement('script'); js.id = id; js.async = true;
                js.src = "//connect.facebook.net/en_US/all.js";
                ref.parentNode.insertBefore(js, ref);
            }(document));
            
            function fb_login() {
                FB.login(function(response) {
                    if (response.authResponse) {
                        update_fb_api(response);
                    } else {
                        console.log('User cancelled login or did not fully authorize.');
                    }
                }, {
                    scope: 'publish_stream, email'
                });
            }
            
            function update_fb_api(response) {
                console.log('Welcome! Fetching your information... ');
                $("#social").html("Successfully logged in with Facebook. <br> Now you can post streams as status updates.");
                
                access_token = response.authResponse.accessToken;
                user_id = response.authResponse.userID;
                
                FB.api('/me', function(response) {
                    user_email = response.email;
                })
            }
        </script>
                <!--
                Below we include the Login Button social plugin. This button uses the JavaScript SDK to
                present a graphical Login button that triggers the FB.login() function when clicked.
                Learn more about options for the login button plugin:
                /docs/reference/plugins/login/ -->
                <!-- <fb:login-button show-faces="true" autologoutlink="true" size="large" width="100" max-rows="1"></fb:login-button> -->
                <div id="social">
                    <a class="btn fb-button" href="#" onclick="fb_login();">
                        <i class="icon-facebook icon-2x"></i> <span>Log in with Facebook</span>
                    </a>
                </div>
                
    </jsp:body>
</t:wrapper>