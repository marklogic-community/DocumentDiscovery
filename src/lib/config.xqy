xquery version '1.0-ml';

(: Generated on 2012-01-07 by the MarkLogic Application Builder, v1.0 :)
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


module namespace config="http://marklogic.com/appservices/config";
import module namespace asc="http://marklogic.com/appservices/component" at "/lib/standard.xqy";
import module namespace app="custom-app-settings" at "/custom/appfunctions.xqy";
declare namespace xdmp="http://marklogic.com/xdmp";
declare namespace html="http://www.w3.org/1999/xhtml";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";
import module namespace search="http://marklogic.com/appservices/search" at "/MarkLogic/appservices/search/search.xqy";
declare variable $ADDITIONAL-CSS := $app:ADDITIONAL-CSS;
declare variable $ADDITIONAL-JS := $app:ADDITIONAL-JS;
declare variable $CONTEXT :=
  <context>{
      for $i in xdmp:get-request-field-names()
      return element { $i } { xdmp:get-request-field($i) },
      <user>{ xdmp:get-request-username() }</user>
    }</context>;
declare variable $DETAIL := if ($CONTEXT/uri) then fn:doc($CONTEXT/uri) else ();
declare variable $FACET-LIMIT :=
  if (fn:empty($app:FACET-LIMIT))
  then $FACET-LIMIT-STANDARD
  else $app:FACET-LIMIT;
declare variable $FACET-LIMIT-STANDARD := 5;
declare variable $INTRO-OPTIONS :=
  if (fn:empty($app:INTRO-OPTIONS))
  then $OPTIONS-STANDARD
  else $app:INTRO-OPTIONS;
declare variable $INTRO-OPTIONS-STANDARD :=
  <options xmlns="http://marklogic.com/appservices/search">
  <constraint name="Author">
    <range collation="http://marklogic.com/collation/" type="xs:string">
      <facet-option>frequency-order</facet-option>
      <facet-option>descending</facet-option>
      <facet-option>limit=10</facet-option>
      <field name="Author"/>
    </range>
    <annotation><proj:front-page xmlns:proj="http://marklogic.com/appservices/project">false</proj:front-page><proj:side-bar xmlns:proj="http://marklogic.com/appservices/project">true</proj:side-bar></annotation>
  </constraint>
  <constraint name="size">
    <range type="xs:int">
      <bucket ge="1048577" name="large">greater than 1MB</bucket>
      <bucket lt="1048576" ge="1025" name="medium">1k through 1MB</bucket>
      <bucket lt="1025" ge="0" name="small">0 through 1k</bucket>
      <facet-option>frequency-order</facet-option>
      <facet-option>descending</facet-option>
      <facet-option>limit=10</facet-option>
      <element ns="http://www.w3.org/1999/xhtml" name="size"/>
    </range>
    <annotation><proj:front-page xmlns:proj="http://marklogic.com/appservices/project">true</proj:front-page><proj:side-bar xmlns:proj="http://marklogic.com/appservices/project">true</proj:side-bar></annotation>
  </constraint>
  <constraint name="ContentType">
    <range collation="http://marklogic.com/collation/" type="xs:string">
      <facet-option>frequency-order</facet-option>
      <facet-option>descending</facet-option>
      <facet-option>limit=10</facet-option>
      <element ns="http://www.w3.org/1999/xhtml" name="content-type"/>
    </range>
    <annotation><proj:front-page xmlns:proj="http://marklogic.com/appservices/project">false</proj:front-page><proj:side-bar xmlns:proj="http://marklogic.com/appservices/project">true</proj:side-bar></annotation>
  </constraint>
  <return-results>false</return-results>
       { $app:ADDITIONAL-INTRO-OPTIONS }
     </options>;
declare variable $LABELS :=
  if (fn:empty($app:LABELS))
  then $LABELS-STANDARD
  else $app:LABELS;
declare variable $LABELS-STANDARD :=
  <lbl:labels xmlns:lbl="http://marklogic.com/xqutils/labels">
  <lbl:label key="relevance">
    <lbl:value xml:lang="en">Relevance</lbl:value>
  </lbl:label>
  <lbl:label key="Size">
    <lbl:value xml:lang="en">Size</lbl:value>
  </lbl:label>
  <lbl:label key="">
    <lbl:value xml:lang="en"/>
  </lbl:label>
  <lbl:label key="">
    <lbl:value xml:lang="en">Author</lbl:value>
  </lbl:label>
  <lbl:label key="size">
    <lbl:value xml:lang="en">Size</lbl:value>
  </lbl:label>
  <lbl:label key="ContentType">
    <lbl:value xml:lang="en">Document Type</lbl:value>
  </lbl:label>
  <lbl:label key="Commenter">
    <lbl:value xml:lang="en">Commenter</lbl:value>
  </lbl:label>
  <lbl:label key="Rating">
    <lbl:value xml:lang="en">Rating</lbl:value>
  </lbl:label>
</lbl:labels>;
declare variable $OPTIONS :=
  if (fn:empty($app:OPTIONS))
  then $OPTIONS-STANDARD
  else $app:OPTIONS;
declare variable $OPTIONS-STANDARD :=
  <options xmlns="http://marklogic.com/appservices/search">
  <search-option>unfiltered</search-option>
  <page-length>10</page-length>
  <term>
    <empty apply="all-results"/>
    <term-option>punctuation-insensitive</term-option>
  </term>
  <grammar>
    <quotation>"</quotation>
    <implicit>
      <cts:and-query strength="20" xmlns:cts="http://marklogic.com/cts"/>
    </implicit>
    <starter strength="30" apply="grouping" delimiter=")">(</starter>
    <starter strength="40" apply="prefix" element="cts:not-query">-</starter>
    <joiner strength="10" apply="infix" element="cts:or-query" tokenize="word">OR</joiner>
    <joiner strength="20" apply="infix" element="cts:and-query" tokenize="word">AND</joiner>
    <joiner strength="30" apply="infix" element="cts:near-query" tokenize="word">NEAR</joiner>
    <joiner strength="30" apply="near2" consume="2" element="cts:near-query">NEAR/</joiner>
    <joiner strength="50" apply="constraint">:</joiner>
    <joiner strength="50" apply="constraint" compare="LT" tokenize="word">LT</joiner>
    <joiner strength="50" apply="constraint" compare="LE" tokenize="word">LE</joiner>
    <joiner strength="50" apply="constraint" compare="GT" tokenize="word">GT</joiner>
    <joiner strength="50" apply="constraint" compare="GE" tokenize="word">GE</joiner>
    <joiner strength="50" apply="constraint" compare="NE" tokenize="word">NE</joiner>
  </grammar>
  <search:extract-metadata>
     <search:constraint-value ref="Rating"/>
  </search:extract-metadata>
  <constraint name="Author">
    <range collation="http://marklogic.com/collation/" type="xs:string" facet="true">
      <facet-option>frequency-order</facet-option>
      <facet-option>descending</facet-option>
      <facet-option>limit=10</facet-option>
      <field name="Author"/>
    </range>
    <annotation><proj:front-page xmlns:proj="http://marklogic.com/appservices/project">false</proj:front-page><proj:side-bar xmlns:proj="http://marklogic.com/appservices/project">true</proj:side-bar></annotation>
  </constraint>
  <constraint name="Rating">
    <range collation="http://marklogic.com/collation/" type="xs:string" facet="true">
      <facet-option>limit=5</facet-option>
      <element ns="http://www.w3.org/1999/xhtml" name="rating"/>
    </range>
    <annotation><proj:front-page xmlns:proj="http://marklogic.com/appservices/project">false</proj:front-page><proj:side-bar xmlns:proj="http://marklogic.com/appservices/project">true</proj:side-bar></annotation>
  </constraint>
  <constraint name="Commenter">
    <range collation="http://marklogic.com/collation/" type="xs:string" facet="true">
      <facet-option>frequency-order</facet-option>
      <facet-option>descending</facet-option>
      <facet-option>limit=10</facet-option>
      <element ns="http://www.w3.org/1999/xhtml" name="Commenter"/>
    </range>
    <annotation><proj:front-page xmlns:proj="http://marklogic.com/appservices/project">false</proj:front-page><proj:side-bar xmlns:proj="http://marklogic.com/appservices/project">true</proj:side-bar></annotation>
  </constraint>
  <constraint name="size">
    <range type="xs:int" facet="true">
      <bucket ge="1048577" name="large">greater than 1MB</bucket>
      <bucket lt="1048576" ge="1025" name="medium">1k through 1MB</bucket>
      <bucket lt="1025" ge="0" name="small">0 through 1k</bucket>
      <facet-option>frequency-order</facet-option>
      <facet-option>descending</facet-option>
      <facet-option>limit=10</facet-option>
      <element ns="http://www.w3.org/1999/xhtml" name="size"/>
    </range>
    <annotation><proj:front-page xmlns:proj="http://marklogic.com/appservices/project">true</proj:front-page><proj:side-bar xmlns:proj="http://marklogic.com/appservices/project">true</proj:side-bar></annotation>
  </constraint>
  <constraint name="ContentType">
    <range collation="http://marklogic.com/collation/" type="xs:string" facet="true">
      <facet-option>frequency-order</facet-option>
      <facet-option>descending</facet-option>
      <facet-option>limit=10</facet-option>
      <element ns="http://www.w3.org/1999/xhtml" name="content-type"/>
    </range>
    <annotation><proj:front-page xmlns:proj="http://marklogic.com/appservices/project">false</proj:front-page><proj:side-bar xmlns:proj="http://marklogic.com/appservices/project">true</proj:side-bar></annotation>
  </constraint>
  <operator name="sort">
    <state name="relevance">
      <sort-order>
	<score/>
      </sort-order>
    </state>
    <state name="Size">
      <sort-order direction="descending" type="xs:int">
	<element ns="http://www.w3.org/1999/xhtml" name="size"/>
      </sort-order>
      <sort-order>
	<score/>
      </sort-order>
    </state>
  </operator>
  <transform-results apply="snippet">
    <preferred-elements><element ns="http://www.w3.org/1999/xhtml" name="p"/><element ns="http://www.w3.org/1999/xhtml" name="body"/></preferred-elements>
    <max-matches>1</max-matches>
    <max-snippet-chars>150</max-snippet-chars>
    <per-match-tokens>20</per-match-tokens>
  </transform-results>
  <return-query>1</return-query>
  <operator name="results">
    <state name="compact">
      <transform-results apply="snippet">
	<preferred-elements><element ns="http://www.w3.org/1999/xhtml" name="p"/><element ns="http://www.w3.org/1999/xhtml" name="body"/></preferred-elements>
	<max-matches>1</max-matches>
	<max-snippet-chars>150</max-snippet-chars>
	<per-match-tokens>20</per-match-tokens>
      </transform-results>
    </state>
    <state name="detailed">
      <transform-results apply="snippet">
	<preferred-elements><element ns="http://www.w3.org/1999/xhtml" name="p"/><element ns="http://www.w3.org/1999/xhtml" name="body"/></preferred-elements>
	<max-matches>2</max-matches>
	<max-snippet-chars>400</max-snippet-chars>
	<per-match-tokens>30</per-match-tokens>
      </transform-results>
    </state>
  </operator>
                { $app:ADDITIONAL-OPTIONS }
            </options>;
declare variable $RESPONSE :=
  if ($CONTEXT/view = ("search", "intro"))
  then
    let $q := ($CONTEXT/q, "")[1]
    let $start :=
      if ($CONTEXT/start castable as xs:unsignedLong)
      then xs:unsignedLong($CONTEXT/start)
      else ()
    return
      search:search(
        $q,
        if ($CONTEXT/view eq "search")
        then $OPTIONS
        else $INTRO-OPTIONS,
        $start)
  else
    ();
declare variable $SLOTS :=
  <slots xmlns="http://marklogic.com/appservices/slots">
  <data-location/>
  <skin>dusk</skin>
  <copyright-holder>MarkLogic Corporation</copyright-holder>
  <copyright-year>2012</copyright-year>
  <logo-src>http://www.ngen.com/images/masthead.jpg</logo-src>
  <logo-text>Document Discovery</logo-text>
  <logo-type>text</logo-type>
  <page-title>Document Discovery</page-title>
</slots>;
declare variable $TRANSFORM-ABSTRACT-METADATA := "/custom/apptransform-abstract-metadata.xsl";
declare variable $TRANSFORM-ABSTRACT-TITLE := "/custom/apptransform-abstract-title.xsl";
declare variable $TRANSFORM-DETAIL := "/custom/apptransform-detail.xsl";
declare variable $page :=
  if (fn:function-available("app:page"))
  then xdmp:function(xs:QName("app:page"))
  else xdmp:function(xs:QName("asc:page"));
declare variable $bootstrap :=
  if (fn:function-available("app:bootstrap"))
  then xdmp:function(xs:QName("app:bootstrap"))
  else
    xdmp:function(
      fn:QName(
        "http://marklogic.com/appservices/component",
        "bootstrap"));
declare variable $browse :=
  if (fn:function-available("app:browse"))
  then xdmp:function(xs:QName("app:browse"))
  else
    xdmp:function(
      fn:QName(
        "http://marklogic.com/appservices/component", "browse"));
declare variable $browse-facets :=
  if (fn:function-available("app:browse-facets"))
  then xdmp:function(xs:QName("app:browse-facets"))
  else
    xdmp:function(
      fn:QName(
        "http://marklogic.com/appservices/component",
        "browse-facets"));
declare variable $canvas :=
  if (fn:function-available("app:canvas"))
  then xdmp:function(xs:QName("app:canvas"))
  else
    xdmp:function(
      fn:QName(
        "http://marklogic.com/appservices/component", "canvas"));
declare variable $chiclet :=
  if (fn:function-available("app:chiclet"))
  then xdmp:function(xs:QName("app:chiclet"))
  else
    xdmp:function(
      fn:QName(
        "http://marklogic.com/appservices/component",
        "chiclet"));
declare variable $contact :=
  if (fn:function-available("app:contact"))
  then xdmp:function(xs:QName("app:contact"))
  else
    xdmp:function(
      fn:QName(
        "http://marklogic.com/appservices/component",
        "contact"));
declare variable $content :=
  if (fn:function-available("app:content"))
  then xdmp:function(xs:QName("app:content"))
  else
    xdmp:function(
      fn:QName(
        "http://marklogic.com/appservices/component",
        "content"));
declare variable $css :=
  if (fn:function-available("app:css"))
  then xdmp:function(xs:QName("app:css"))
  else
    xdmp:function(
      fn:QName(
        "http://marklogic.com/appservices/component", "css"));
declare variable $doctype :=
  if (fn:function-available("app:doctype"))
  then xdmp:function(xs:QName("app:doctype"))
  else
    xdmp:function(
      fn:QName(
        "http://marklogic.com/appservices/component",
        "doctype"));
declare variable $error-message :=
  if (fn:function-available("app:error-message"))
  then xdmp:function(xs:QName("app:error-message"))
  else
    xdmp:function(
      fn:QName(
        "http://marklogic.com/appservices/component",
        "error-message"));
declare variable $facet-chiclet :=
  if (fn:function-available("app:facet-chiclet"))
  then xdmp:function(xs:QName("app:facet-chiclet"))
  else
    xdmp:function(
      fn:QName(
        "http://marklogic.com/appservices/component",
        "facet-chiclet"));
declare variable $facet-extract :=
  if (fn:function-available("app:facet-extract"))
  then xdmp:function(xs:QName("app:facet-extract"))
  else
    xdmp:function(
      fn:QName(
        "http://marklogic.com/appservices/component",
        "facet-extract"));
declare variable $facet-toggle-content :=
  if (fn:function-available("app:facet-toggle-content"))
  then xdmp:function(xs:QName("app:facet-toggle-content"))
  else
    xdmp:function(
      fn:QName(
        "http://marklogic.com/appservices/component",
        "facet-toggle-content"));
declare variable $facets :=
  if (fn:function-available("app:facets"))
  then xdmp:function(xs:QName("app:facets"))
  else
    xdmp:function(
      fn:QName(
        "http://marklogic.com/appservices/component", "facets"));
declare variable $footer :=
  if (fn:function-available("app:footer"))
  then xdmp:function(xs:QName("app:footer"))
  else
    xdmp:function(
      fn:QName(
        "http://marklogic.com/appservices/component", "footer"));
declare variable $get-content :=
  if (fn:function-available("app:get-content"))
  then xdmp:function(xs:QName("app:get-content"))
  else
    xdmp:function(
      fn:QName(
        "http://marklogic.com/appservices/component",
        "get-content"));
declare variable $header :=
  if (fn:function-available("app:header"))
  then xdmp:function(xs:QName("app:header"))
  else
    xdmp:function(
      fn:QName(
        "http://marklogic.com/appservices/component", "header"));
declare variable $help :=
  if (fn:function-available("app:help"))
  then xdmp:function(xs:QName("app:help"))
  else
    xdmp:function(
      fn:QName(
        "http://marklogic.com/appservices/component", "help"));
declare variable $item-render :=
  if (fn:function-available("app:item-render"))
  then xdmp:function(xs:QName("app:item-render"))
  else
    xdmp:function(
      fn:QName(
        "http://marklogic.com/appservices/component",
        "item-render"));
declare variable $js :=
  if (fn:function-available("app:js"))
  then xdmp:function(xs:QName("app:js"))
  else
    xdmp:function(
      fn:QName(
        "http://marklogic.com/appservices/component", "js"));
declare variable $logo :=
  if (fn:function-available("app:logo"))
  then xdmp:function(xs:QName("app:logo"))
  else
    xdmp:function(
      fn:QName(
        "http://marklogic.com/appservices/component", "logo"));
declare variable $null :=
  if (fn:function-available("app:null"))
  then xdmp:function(xs:QName("app:null"))
  else
    xdmp:function(
      fn:QName(
        "http://marklogic.com/appservices/component", "null"));
declare variable $remove-facet :=
  if (fn:function-available("app:remove-facet"))
  then xdmp:function(xs:QName("app:remove-facet"))
  else
    xdmp:function(
      fn:QName(
        "http://marklogic.com/appservices/component",
        "remove-facet"));
declare variable $result-metadata :=
  if (fn:function-available("app:result-metadata"))
  then xdmp:function(xs:QName("app:result-metadata"))
  else
    xdmp:function(
      fn:QName(
        "http://marklogic.com/appservices/component",
        "result-metadata"));
declare variable $result-navigation :=
  if (fn:function-available("app:result-navigation"))
  then xdmp:function(xs:QName("app:result-navigation"))
  else
    xdmp:function(
      fn:QName(
        "http://marklogic.com/appservices/component",
        "result-navigation"));
declare variable $result-title :=
  if (fn:function-available("app:result-title"))
  then xdmp:function(xs:QName("app:result-title"))
  else
    xdmp:function(
      fn:QName(
        "http://marklogic.com/appservices/component",
        "result-title"));
declare variable $result-toggle :=
  if (fn:function-available("app:result-toggle"))
  then xdmp:function(xs:QName("app:result-toggle"))
  else
    xdmp:function(
      fn:QName(
        "http://marklogic.com/appservices/component",
        "result-toggle"));
declare variable $results :=
  if (fn:function-available("app:results"))
  then xdmp:function(xs:QName("app:results"))
  else
    xdmp:function(
      fn:QName(
        "http://marklogic.com/appservices/component",
        "results"));
declare variable $searchbox :=
  if (fn:function-available("app:searchbox"))
  then xdmp:function(xs:QName("app:searchbox"))
  else
    xdmp:function(
      fn:QName(
        "http://marklogic.com/appservices/component",
        "searchbox"));
declare variable $sidebar :=
  if (fn:function-available("app:sidebar"))
  then xdmp:function(xs:QName("app:sidebar"))
  else
    xdmp:function(
      fn:QName(
        "http://marklogic.com/appservices/component",
        "sidebar"));
declare variable $sidebar-header :=
  if (fn:function-available("app:sidebar-header"))
  then xdmp:function(xs:QName("app:sidebar-header"))
  else
    xdmp:function(
      fn:QName(
        "http://marklogic.com/appservices/component",
        "sidebar-header"));
declare variable $skin :=
  if (fn:function-available("app:skin"))
  then xdmp:function(xs:QName("app:skin"))
  else
    xdmp:function(
      fn:QName(
        "http://marklogic.com/appservices/component", "skin"));
declare variable $sort-menu :=
  if (fn:function-available("app:sort-menu"))
  then xdmp:function(xs:QName("app:sort-menu"))
  else
    xdmp:function(
      fn:QName(
        "http://marklogic.com/appservices/component",
        "sort-menu"));
declare variable $sort-menu-content :=
  if (fn:function-available("app:sort-menu-content"))
  then xdmp:function(xs:QName("app:sort-menu-content"))
  else
    xdmp:function(
      fn:QName(
        "http://marklogic.com/appservices/component",
        "sort-menu-content"));
declare variable $terms :=
  if (fn:function-available("app:terms"))
  then xdmp:function(xs:QName("app:terms"))
  else
    xdmp:function(
      fn:QName(
        "http://marklogic.com/appservices/component", "terms"));
declare variable $toolbar :=
  if (fn:function-available("app:toolbar"))
  then xdmp:function(xs:QName("app:toolbar"))
  else
    xdmp:function(
      fn:QName(
        "http://marklogic.com/appservices/component",
        "toolbar"));
declare variable $transform-result :=
  if (fn:function-available("app:transform-result"))
  then xdmp:function(xs:QName("app:transform-result"))
  else
    xdmp:function(
      fn:QName(
        "http://marklogic.com/appservices/component",
        "transform-result"));
declare variable $transform-snippet :=
  if (fn:function-available("app:transform-snippet"))
  then xdmp:function(xs:QName("app:transform-snippet"))
  else
    xdmp:function(
      fn:QName(
        "http://marklogic.com/appservices/component",
        "transform-snippet"));
declare variable $user :=
  if (fn:function-available("app:user"))
  then xdmp:function(xs:QName("app:user"))
  else
    xdmp:function(
      fn:QName(
        "http://marklogic.com/appservices/component", "user"));
