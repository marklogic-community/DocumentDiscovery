xquery version "1.0-ml";

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

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare function local:construct-new($url as xs:string,$pattern as xs:string,$view as xs:string)
as xs:string
{
    let $args := substring-after($url,$pattern)
    return concat("/main.xqy?uri=",replace($args, "\?", "&amp;"),"&amp;view=",$view)
};

let $url := xdmp:get-request-url()
let $new-url :=
    if (fn:matches($url,"^/search"))
        then local:construct-new($url,"/search","search")
    else 
        if (fn:matches($url,"^/detail"))
        then local:construct-new($url,"/detail","detail")
    else 
       if (fn:matches($url,"^/help")) 
       then local:construct-new($url,"/help","help")
    else 
       if (fn:matches($url,"^/contact")) 
       then local:construct-new($url,"/contact","contact")
    else 
       if (fn:matches($url,"^/terms")) 
       then local:construct-new($url,"/terms","terms")
    else 
       if (fn:matches($url,"^/$"))
       then local:construct-new($url,"/","intro")
    else $url
return $new-url
