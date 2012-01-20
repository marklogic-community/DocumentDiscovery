/* Copyright 2002-2011 MarkLogic Corporation.  All Rights Reserved. */

/*

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

*/

YAHOO.util.Event.addListener(window, "load", function() {
    var blink = document.getElementById('bootstrap_link');
    YAHOO.util.Event.addListener(blink, "click", 
        function () {    
            var bootstrap = document.getElementById('bootstrap');
            var url = "/load.xqy";
            var handleSuccess = function(o) {
                   if (o.responseText !== undefined){ 
                    window.location = "/";
                  } 
            };
            var handleFailure = function(o) {
                 if (o.responseText !== undefined){ 
                    bootstrap.innerHTML = '<span class="error">Unable to load dataset.</span>'; 
                 } 
            };
            var callback = {
                 success:handleSuccess,
                 failure:handleFailure
            }
            YAHOO.util.Connect.asyncRequest('GET', url, callback); 
            bootstrap.innerHTML = '<div><img src="/images/loading.gif"/> Loading, please wait. </div>'; 
        }); 
               
});
