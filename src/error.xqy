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

declare namespace xs="http://www.w3.org/2001/XMLSchema";
declare namespace admin="http://marklogic.com/xdmp/admin";

declare default element namespace "http://www.w3.org/1999/xhtml";

import module namespace asc= "http://marklogic.com/appservices/component" at "/lib/standard.xqy";
import module namespace config="http://marklogic.com/appservices/config" at "/lib/config.xqy";

declare variable $error:errors as node()* external;

let $responseCode := xdmp:get-response-code()[1]
return
if ($responseCode = 401)
then
	<html xmlns="http://www.w3.org/1999/xhtml">
		<head><title>401 Unauthorized</title><meta name="robots" content="noindex,nofollow"/></head>
		<body><h1>401 Unauthorized</h1></body>
	</html>
else
(
let $head := 
    try {
        <head>
            <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
            <?import namespace="v" implementation="#default#VML" ?>
            <title>{$config:SLOTS/*:page-title/string()}</title>
            {xdmp:apply($config:css)}
            {xdmp:apply($config:js)}
        </head>
    }
    catch($e)
    {
        <head>
            <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
            <?import namespace="v" implementation="#default#VML" ?>
            <title>{$config:SLOTS/*:page-title/string()}</title>
            <link href="/yui/fonts/fonts-min.css" media="screen" rel="stylesheet" type="text/css"/>
            {
                if ($config:SLOTS/*:skin)
                then <link type="text/css" rel="stylesheet" media="screen" 
                            href="{ concat('/skins/',$config:SLOTS/*:skin/string(),"/",$config:SLOTS/*:skin/string(), '.css')  }"/>
                else  <link type="text/css" rel="stylesheet" media="screen" href="/css/master.css"/>
            }
            <!--[if IE 8]><link href="/css/ie_8.css" media="screen" rel="stylesheet" type="text/css" /><![endif]-->
            <!--[if IE 7]><link href="/css/ie_7.css" media="screen" rel="stylesheet" type="text/css" /><![endif]-->
            <!--[if lte IE 6]><link href="/css/ie_6.css" media="screen" rel="stylesheet" type="text/css" /><![endif]-->
            <link rel="stylesheet" type="text/css" href="/css/custom.css"/>

            <link type="text/css" rel="stylesheet" media="screen" href="/css/master.css"/>
        </head>
    }
let $body := 
    try {
        <body class="yui-skin-sam">
            {xdmp:apply( $config:logo )}
            {xdmp:apply($config:user)}
            <div class="canvas">
                {xdmp:apply($config:header)}
                <div class="content">
                    <div class="content-background"><!-- --></div>
                    <div class="error">
                        <h1>Sorry, an error has occurred.</h1>
                        <div class="error-detail">
                            {
                                concat("Error: ",string-join(for $i in xdmp:get-response-code() return string($i)," "))
                            }
                            <div>More information is available in the server's error log.</div>
                        </div>
                        <div>Go back to the <a href="/">home page</a>.</div>
                    </div>
                    <div class="canvas-break">&nbsp;</div>
                </div>
                {xdmp:apply($config:footer)}
            </div>
        </body>
    }
    catch ($e)
    {
        <body class="yui-skin-sam">
            <div class="canvas">
                <div class="content">
                    <div class="content-background"><!-- --></div>
                    <div class="error">
                        <h1>Sorry, an error has occurred.</h1>
                        <div class="error-detail">
                            {
                                concat("Error: ",string-join(for $i in xdmp:get-response-code() return string($i)," "))
                            }
                            <div>More information is available in the server's error log.</div>
                        </div>
                        <div>Go back to the <a href="/">home page</a>.</div>
                    </div>
                    <div class="canvas-break">&nbsp;</div>
                </div>
            </div>
        </body>
    }
return
<html xmlns:v="urn:schemas-microsoft-com:vml" xml:lang="en" lang="en">
    {$head}
    {$body}
</html>
)

