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

import module namespace search = "http://marklogic.com/appservices/search" at "MarkLogic/appservices/search/search.xqy";
import module namespace config="http://marklogic.com/appservices/config" at "/lib/config.xqy";

declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare option xdmp:mapping "false";

declare variable $local:PQTXT := xdmp:get-request-field("pqtxt");

try {
  if ($local:PQTXT) then search:suggest($local:PQTXT,$config:OPTIONS)
  else ()
}

catch($e)
{
  (xdmp:log(xdmp:quote($e)),
  ())
}
