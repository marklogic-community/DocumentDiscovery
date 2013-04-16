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
let $comments := xdmp:get-request-field('c')
let $name := xdmp:get-request-field('n')
let $_ := xdmp:log(fn:concat("*****", $name, "***", $comments))

let $insert-comments :=
  if (fn:exists(fn:doc($uri)//html:head/html:Comments)) then
    xdmp:node-replace(
      fn:doc($uri)//html:head/html:Comments,
      element {xs:QName("html:Comments")} {$comments}
    )
  else
  xdmp:node-insert-after(
    fn:doc($uri)//html:head/*[fn:last()],
    element {xs:QName("html:Comments")} {$comments}
  )

let $insert-commenter-name :=
  if (fn:exists(fn:doc($uri)//html:head/html:Commenter)) then
    xdmp:node-replace(
      fn:doc($uri)//html:head/html:Commenter,
      element {xs:QName("html:Commenter")} {$name}
    )
  else
  xdmp:node-insert-after(
    fn:doc($uri)//html:head/*[fn:last()],
    element {xs:QName("html:Commenter")} {$name}
  )
return ()