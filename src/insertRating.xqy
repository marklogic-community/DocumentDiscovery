xquery version '1.0-ml';

(: Copyright 2002-2011 MarkLogic Corporation.  All Rights Reserved. :)

(:

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	 http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

:) 

declare namespace html = "http://www.w3.org/1999/xhtml";

let $uri := xdmp:get-request-field('uri')
let $doc := fn:doc($uri)
let $rating := fn:concat(xdmp:get-request-field('r'), " Star")
let $_ := xdmp:log(fn:concat("** insert **", $rating))

let $insert-rating :=
  if (fn:exists(fn:doc($uri)//html:head/html:rating)) then
    ((xdmp:node-replace(
      fn:doc($uri)//html:head/html:rating,
      element {xs:QName("html:rating")} {$rating}
    ),xdmp:log("** rating: replace existing **"))
    )
  else
    ((xdmp:node-insert-after(
    fn:doc($uri)//html:head/*[fn:last()],
    element {xs:QName("html:rating")} {$rating}
      ),xdmp:log(fn:concat("** rating: insert after existing**")))
  )

return ()