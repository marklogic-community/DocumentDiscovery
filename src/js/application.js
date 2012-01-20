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

YAHOO.util.Event.onDOMReady(function() {

    var home = document.getElementById('home');
    YAHOO.util.Event.addListener(home, "click",
       function () {
            window.location = "/";
        });
    
    var oDS = new YAHOO.util.XHRDataSource("/suggest.xqy");
    oDS.responseType = YAHOO.util.XHRDataSource.TYPE_TEXT;
    oDS.responseSchema = {
        recordDelim: "\n",
        fieldDelim: "\t"
    };
       
    oDS.maxCacheEntries = 5;
    var oAC = new YAHOO.widget.AutoComplete("q", "suggestions", oDS);
    oAC.animVert = true; 
    oAC.maxResultsDisplayed = 5; 
    oAC.useShadow = true;

/* This handler is called by autocomplete when focus leaves the search input
   box. That makes tabbing (or indeed clicking anywhere) off the input box
   automatically submit the form. That seems wrong. And removing this handler
   doesn't seem to have an adverse effect on the app...

    var updateHandler = function(sType, aArgs) {  
        var searchform = document.getElementById('searchform');
        searchform.submit(); 
    };  
    oAC.unmatchedItemSelectEvent.subscribe(updateHandler); 
*/

    oAC.generateRequest = function(sQuery) {
        return "?pqtxt=" + sQuery ;
    };
       
    return {
        oDS: oDS,
        oAC: oAC
    };

});

var ListToggler;
(function(){
  var dom = YAHOO.util.Dom;
  var ev = YAHOO.util.Event;
  var anim = YAHOO.util.Anim;
  var menu = YAHOO.widget.Menu;
  
  ListToggler = function(items){
    this.items = items;
    ev.onDOMReady(function(){
      if(this.items){
        for(var i=0; i<this.items.length; i++){
          var item = this.items[i];
          item.controller = dom.get(item.controller);
          item.list = dom.get(item.list);
          item.toggle = (function(item){
            return function(){
              var animation = new anim(item.list, {height: {to: (item.isCollapsed ? item.list.scrollHeight : 0)}}, 0.3, YAHOO.util.Easing.easeIn); 
              animation.animate();
              animation.onComplete.subscribe(function(){
                item.isCollapsed = item.isCollapsed==false
                item.controller.innerHTML = item.isCollapsed ? item.openTitle : item.closedTitle;
              });
            }
            })(item)
          ev.addListener(item.controller, 'click', item.toggle);
        }
      }
    }, null, this);
  }
  
  ev.onDOMReady(function(){
    
    var categories = dom.getElementsByClassName('category');
    // Loop throught the collection of the categories in the sidebar, and add toggle functionality for the headers
    for(var i=0; i<categories.length; i++){
      var header = categories[i].getElementsByTagName("h4").item(0);
      var listing = categories[i].getElementsByTagName("ul").item(0);
      if(header && listing){
        ev.addListener(header, 'click', (function(list, head){
          return function(){
            var fold = list.offsetHeight == 0;
            var to_height = (fold) ? list.scrollHeight : 0;
            var animation = new anim(list, {height: {to: to_height}}, 0.3, YAHOO.util.Easing.easeIn);
            animation.onComplete.subscribe(function(){
              if(fold) list.style.height = "auto";
            });
            animation.animate(); 
          }
        })(listing, header));
      }
    }
    
    
    if(sort_menu_content){
      var sort_menu_controller = dom.get("sort_menu_controller");
      var sort_menu_pos = dom.getRegion(sort_menu_controller)
      var sort_menu = new menu("sort_menu_element", { xy:[sort_menu_pos.left,sort_menu_pos.bottom] });
      sort_menu.addItems(sort_menu_content);
      sort_menu.render(document.body);
      sort_menu.moveTo(sort_menu_pos.right-sort_menu.element.clientWidth,sort_menu_pos.bottom);
      sort_menu.beforeShowEvent.subscribe(function(){
        dom.addClass(sort_menu_controller, "menu-selected")
      });
      sort_menu.beforeHideEvent.subscribe(function(){
        dom.removeClass(sort_menu_controller, "menu-selected")
      });
      ev.addListener(sort_menu_controller, "click", sort_menu.show, null, sort_menu);
    }
    
  });

})();
