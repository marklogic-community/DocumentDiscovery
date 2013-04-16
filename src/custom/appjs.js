/* Add any custom scripting for your built app here.
 * This file will survive redeployment.
 */
$(function() {
/*
  $(".category category-4") {
  
    <div id="star"></div>
          
    <div class="category category-4"><h4 title="Collapse Rating category">Rating</h4>
      <ul>
    	    <li><a href="/search?q=Rating%3A%221%20Star%22">1 Star</a><i> (2)</i></li>
    	    <li><a href="/search?q=Rating%3A%222%20Star%22">2 Star</a><i> (2)</i></li>
    	    <li><a href="/search?q=Rating%3A%223%20Star%22">3 Star</a><i> (2)</i></li>
    	    <li><a href="/search?q=Rating%3A%224%20Star%22">4 Star</a><i> (4)</i></li>
    	    <li><a href="/search?q=Rating%3A%225%20Star%22">5 Star</a><i> (1)</i></li>
    	</ul>
    </div>
        
    var $x = (this);
    
    $('#star').raty({ readOnly: true, score: 1 });
    $('#star').raty({ readOnly: true, score: 2 });
    $('#star').raty({ readOnly: true, score: 3 });
    $('#star').raty({ readOnly: true, score: 4 });
    $('#star').raty({ readOnly: true, score: 5 });
    
  }
  */
 
   // $(".category").each(function(index, element) {
   //   
   //   var v = $(this).find("h4").val();
   // 
   //   if (v == "Rating") {
   //     //alert("found it");
   //     // $(this).find('a').after('<div id="facet-star"></div>')
   //   }
   //   
   // });

   /* 
    *  Apply stary image to div embedded in each snippet in the form of:
    *     <div id="snippet-star" rating="5"></div>
    */
   $(".result").each(function(index, element) {
     
    var snip = $(this).find('#snippet-star'),
    num = snip.attr('rating');
          
      snip.raty({ 
        path: '/js/img',
        readOnly: true,
        score: num
      });

   });

   /*
    *  User star rating function on the content details page
    */
   $('#content-rating').raty({ 
     path: '/js/img',
     number: 5,
     width: 320,

     score: function() {
       if ($("p.user-rating").length > 0) {
         // get url from form this element
          var rating = $("p.user-rating").text();
          
          // string is "User Rating: 5 Star"
          var num = rating.charAt(13);
          
          return num;
        } else {
          return 0;
        }
     },
     
     click: function(score, evt) {
           
       // get url from form this element
        var $div = $(this),
        url = $div.find('.insert-star').attr('href');
        
        var $rating = score;

        // send data using post
        var posting = $.post(url, {r: score});
       }
   });
   
   $( "#dialog-form" ).dialog({
     autoOpen: false,
     height: 300,
     width: 300,
     modal: true,
     buttons: {
       "Save": function(event) {
         
         $( this ).dialog( "close" );
         
         // get values from form element
          var $div = $(this),
          comments = $div.find('textarea[name="comment-box"]').val(),
          name = $div.find('input[name="username"]').val(),
          url = $div.find('form').attr('action');
          
          // send data using post
          var posting = $.post(url, {c: comments, n: name});

          /* Put the results in a div */
          posting.done(function() {
            setTimeout(function() { 
              location.reload();}, 1 );
          });
       },
       Cancel: function() {
         $( this ).dialog( "close" );
       }
     }
   });

   $( ".edit-comments" )
     .click(function() {
       $( "#dialog-form" ).dialog( "open" );
     });
     
 });