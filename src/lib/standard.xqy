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

module namespace asc = "http://marklogic.com/appservices/component";

import module namespace config="http://marklogic.com/appservices/config" at "/lib/config.xqy";
import module namespace app="custom-app-settings" at "/custom/appfunctions.xqy";

import module namespace search = "http://marklogic.com/appservices/search" 
    at "/MarkLogic/appservices/search/search.xqy";
import module namespace trans = "http://marklogic.com/translate" 
    at "/MarkLogic/appservices/utils/translate.xqy";
import module namespace render="http://marklogic.com/renderapi" 
    at "/MarkLogic/appservices/utils/renderapi.xqy";
import module namespace boot="http://marklogic.com/appservices/bootstrap" 
    at "/MarkLogic/appservices/appbuilder/bootstrap.xqy";

declare namespace proj ="http://marklogic.com/appservices/project";
declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/1999/xhtml";
declare namespace label = "http://marklogic.com/xqutils/labels";
declare namespace slots = "http://marklogic.com/appservices/slots";

declare option xdmp:mapping "false";

(: -------------------------------------------:)
(: Primary functions, easily overridden in custom/appfunctions.xqy  :)

(:~
 : Main entry point, constructs page.
 :)
declare function asc:page()
as element(html)
{
    <html xmlns:v="urn:schemas-microsoft-com:vml" xml:lang="en" lang="en">
    <head>
      <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
      <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE7"/>
      <?import namespace="v" implementation="#default#VML" ?>
      <title>{$config:SLOTS/slots:page-title/string()}</title>
      {xdmp:apply($config:css)}
      {xdmp:apply($config:js)}
    </head>
        <body class="yui-skin-sam">
            {xdmp:apply($config:logo)}
            {xdmp:apply($config:user)}
            {xdmp:apply($config:canvas)}
        </body>
    </html>
};

(:~
 : Control for one-time or startup processing.
 :)
declare function asc:bootstrap()
as element(div)?
{
    ()
};

(:~
 : Main front page content (browse links)
 :)
declare function asc:browse()
as element(div)
{
  <div class="front-page-content">
   {let $front-page := $config:OPTIONS/search:constraint[search:annotation/xs:boolean(proj:front-page) eq true()]/@name
    return xdmp:apply($config:browse-facets, $config:RESPONSE/search:facet[@name = $front-page], ())}
   {xdmp:apply( $config:bootstrap )}
   </div>
};

(:~
 : Canvas for page presentation
 :)
declare function asc:canvas()
as element(div)
{
    <div class="canvas">
         {xdmp:apply($config:header)}
         {xdmp:apply($config:sidebar)}
         {xdmp:apply($config:content)}
         {xdmp:apply($config:footer)}
         <div class="canvas-break">&nbsp;</div>
    </div>
};

(:~
 : Page content
 :)
declare function asc:content()
as element(div)
{
    <div class="content">
    <div class="content-background"><!-- --></div>
       { xdmp:apply($config:get-content) }
    </div>
};

(:~
 : CSS Links, including skins
 :)
declare function asc:css()
as node()*
{
    (<link href="/yui/fonts/fonts-min.css" media="screen" rel="stylesheet" type="text/css"/>,
    <link href="/yui/menu/assets/skins/sam/menu.css" media="screen" rel="stylesheet" type="text/css" />,
    <link href="/yui/autocomplete/assets/skins/sam/autocomplete.css" media="screen" rel="stylesheet" type="text/css" />,
    <link rel="stylesheet" type="text/css" href="/css/jquery-ui/jquery-ui.min.css"/>,   
      if ($config:SLOTS/slots:skin) then xdmp:apply($config:skin,$config:SLOTS/slots:skin) else (),
    <!--[if IE 7]><link href="/css/ie_7.css" media="screen" rel="stylesheet" type="text/css" /><![endif]-->,
    <!--[if lte IE 6]><link href="/css/ie_6.css" media="screen" rel="stylesheet" type="text/css" /><![endif]-->,
    <link rel="stylesheet" type="text/css" href="/css/custom.css"/>,
    $config:ADDITIONAL-CSS
    )
};

(:~
 : Creates sidebar facet display on intro and search results pages.
 :)
declare function asc:facets()
{
    let $side-bar := $config:OPTIONS/search:constraint[search:annotation/xs:boolean(proj:side-bar) eq true()]/@name
    return
    xdmp:apply($config:browse-facets, $config:RESPONSE/search:facet[@name = $side-bar],($config:RESPONSE/search:qtext)[1])
};

(:~
 : Called directly to create browse links on the intro page.
:)
declare function asc:browse-facets($facets as element(search:facet)*,$qtext as xs:string?)
as element(div)*
{
      let $controls := map:map()

      (: In this code, we want to work out which facet "chiclets" to
         present in the browse sidebar. In order to that, we have to
         be able to determine which facets are mentioned in the query.

         This code used to do that by attempting to find the facets in
         the text of the query string. That was potentially inaccurate
         because the code couldn't deal with the full complexity of
         query parsing. If only we had the parsed query ...

         But wait, we do. It's in the same search:results tree as the
         search:facet elements. So now we use the parsed query to work
         out what facets are referenced.

         N.B. This means that the chiclets will stop working if you
         change the search options so that the parsed query isn't in
         the search results. That is considered a fair tradeoff for the
         increased robustness of using the parsed query to determine
         the facet references.
      :)

      (: 1. Get the parsed query :)
      let $query  := $facets[1]/../search:query

      (: 2. Extract from that query, all the uses of a facet :)
      let $quses  := ($query//*[not(self::cts:annotation)]/@qtextpre,
                      $query//*[not(self::cts:annotation)]/@qtextconst)

      (: 3. Extract from those uses, the names of all the facets by
            peeling them off from the their following joiners
      :)
      let $qnames := for $q in $quses
                     for $j in $config:OPTIONS/search:grammar/search:joiner
                                         [@apply='constraint' and not(@compare)]
                     return
                       if (contains($q, $j))
                       then substring-before($q, $j)
                       else ()

      (: 4. If the same name is used more than once, that's not significant :)
      let $qfacet := distinct-values($qnames)

      let $display :=
          for $facet at $index in $facets
          let $facet-name := data($facet/@name)
          let $facet-count := count($facet/search:facet-value)

          (: 5. If the $facet-name matches one of the $qfacet's then we consider making a chiclet :)
          let $match := ($facet-name = $qfacet)

          return
          <div class="category {concat("category-",$index)} { if ($match) then "selected-category" else ()}">
            <h4 title="Collapse {trans:translate($facet-name,$config:LABELS,(),"en")} category">
             { trans:translate($facet-name,$config:LABELS,(),"en")}
            </h4>
            <ul>
              {
              let $list-items :=
                  for $result in $facet/search:facet-value
                  let $facet-val :=
                      if (matches($result/@name/string(),"\W"))
                      then concat('"',$result/@name/string(),'"')
                      else if ($result/@name eq "") then """"
                      else $result/@name/string()
                  let $fq := concat($facet-name, ":",$facet-val)
                  let $newquery :=
                          if ($qtext)
                          then
                             if ($match)
                             then search:remove-constraint($qtext,$fq,$config:OPTIONS)
                             else concat("(",$qtext,")"," AND ",$fq)
                          else $fq
                  let $href := concat("/search?q=",encode-for-uri($newquery))
                  let $title := (trans:translate($result/string(),$config:LABELS,(),"en"),$result/string())[1]
                  return
                  <li>
                     <a href="{$href}">{if ($title eq "") then <em>(empty)</em> else $title}</a><i> ({$result/@count/string()})</i>
                  </li>
              return
              (
              ($list-items)[1 to $config:FACET-LIMIT],
              if ($facet-count > $config:FACET-LIMIT)
              then
              (
              <ul id="all_{$facet-name}">
                     {($list-items)[position() gt $config:FACET-LIMIT]}
               </ul>,
               <li id="view_toggle_{$facet-name}" class="list-toggle">...More</li>)
              else (),
              if ($match)
              then
                  let $chiclet := xdmp:apply($config:facet-chiclet, $qtext,$config:OPTIONS,concat($facet-name,":"))
                  return map:put($controls,$facet-name,$chiclet)
              else ())
            }</ul>
          </div>
      let $selected := $display[data(@class) = "selected-category"]
      let $header :=
          let $msg :=
              if ($selected) then "You are looking at"
              else "Browse"
          return xdmp:apply($config:sidebar-header,$msg)
      let $controls :=
          for $control in map:keys($controls)
          return map:get($controls,$control)

     return ($header,$controls,$display)
};

(:~
 : Default footer content
 :)
declare function asc:footer()
as element(div)
{
     <div class="footer" arcsize="0 0 5 5">
        <span class="copyright">&copy; {$config:SLOTS/slots:copyright-year/string()}, {$config:SLOTS/slots:copyright-holder/string()}, All Rights Reserved.</span>
        <a href="/help">{$config:SLOTS/slots:page-title/string()} Help</a>
        <span class="pipe">&nbsp;</span>
        <a href="/contact">Contact Us</a>
        <span class="pipe">&nbsp;</span>
        <a href="/terms">Terms of Use</a>
    </div>
};

(:~
 : Page header, including search input box.
 :)
declare function asc:header()
as element(div)
{
    <div class="header"  arcsize="5 5 0 0">
        <label>Search</label>
        {xdmp:apply( $config:searchbox )}
    </div>
};

(:~
 : Default item rendering
 :)
declare function asc:item-render()
as element(div)
{
   <div class="detail">
      { xdmp:xslt-invoke($config:TRANSFORM-DETAIL,$config:DETAIL) }
   </div>
};

(:~
 : Base script elements for Javascript.
 :)
declare function asc:js()
as element()*
{
    (<script src="/yui/yahoo-dom-event/yahoo-dom-event.js" type="text/javascript"><!-- --></script>,
     <script src="/yui/container/container_core-min.js" type="text/javascript"><!-- --></script>,
     <script src="/yui/menu/menu-min.js" type="text/javascript"><!-- --></script>,
     <script src="/yui/animation/animation-min.js" type="text/javascript"><!-- --></script>,
     <script src="/yui/datasource/datasource-min.js" type="text/javascript" ><!-- --></script>,
     <script src="/yui/connection/connection-min.js" type="text/javascript"><!-- --></script> ,
     <script src="/yui/autocomplete/autocomplete-min.js" type="text/javascript" ><!-- --></script>,
     <script src="/js/application.js" type="text/javascript"><!-- --></script>,
     <script src="/js/jquery-1.9.1.min.js" type="text/javascript"><!-- --></script>,
     <script src="/js/jquery-ui.min.js" type="text/javascript"><!-- --></script>,
     <script src="/js/jquery.raty.min.js" type="text/javascript"><!-- --></script>,
     $config:ADDITIONAL-JS,
     <script type="text/javascript" charset="utf-8">
            // Sort menu
            {
            if (count($config:OPTIONS/search:operator[@name eq "sort"]/search:state) > 0)
            then concat(
              'var sort_menu_content = [',
               xdmp:apply($config:sort-menu-content,$config:OPTIONS,$config:CONTEXT/*:q,$config:LABELS),
              ']')
            else ()
            }
            // Category toggle
            var toggle_list_size = [
             { xdmp:apply($config:facet-toggle-content,$config:OPTIONS) }
            ]
            new ListToggler(toggle_list_size);
      </script>)
};

(:~
 : Page header, including search input box.
 :)
declare function asc:logo()
as element(div)
{
    <div class="home" id="home" title="Home">
        {
        if ($config:SLOTS/slots:logo-type eq 'graphic')
        then <img src="{$config:SLOTS/slots:logo-src/string()}"/>
        else if ($config:SLOTS/slots:logo-type eq 'text') then <span class="text">{$config:SLOTS/slots:logo-text/string()}</span>
        else ()
        }
    </div>
};

(:~
 : Control for removing selected facet.
 :)
declare function asc:remove-facet()
{
    let $href := concat("/search?q=",if ($config:CONTEXT/*:q) then encode-for-uri($config:CONTEXT/*:q) else (),
                        if ($config:CONTEXT/*:start) then concat("&amp;start=", encode-for-uri($config:CONTEXT/*:start)) else ())
    let $params := map:map()
    let $labels := map:put($params,"{http://marklogic.com/appservices/config}LABELS",$config:LABELS)
    let $title := xdmp:xslt-invoke($config:TRANSFORM-ABSTRACT-TITLE,$config:DETAIL,$params)
    return
    (  xdmp:apply($config:sidebar-header, "You are looking at"),
       xdmp:apply($config:chiclet,$href,$title)
     )
};

(:~
 : Pagination controls for the result page.
 :)
declare function asc:result-navigation()
as element(div)
 {
    let $start := xs:unsignedLong($config:RESPONSE/@start)
    let $length := xs:unsignedLong($config:RESPONSE/@page-length)
    let $total := xs:unsignedLong($config:RESPONSE/@total)
    let $last := xs:unsignedLong($start + $length -1)
    let $end := if ($total > $last) then $last else $total
    let $qtext := $config:RESPONSE/search:qtext[1]/text()
    let $next := if ($total > $last) then $last + 1 else ()
    let $previous := if (($start > 1) and ($start - $length > 0)) then max((($start - $length),1)) else ()
    let $next-href :=
         if ($next)
         then concat("/search?q=",if ($qtext) then encode-for-uri($qtext) else (),"&amp;start=",$next)
         else ()
    let $previous-href :=
         if ($previous)
         then concat("/search?q=",if ($qtext) then encode-for-uri($qtext) else (),"&amp;start=",$previous)
         else ()
    let $total-pages := ceiling($total div $length)
    let $currpage := ceiling($start div $length)
    let $pagemin :=
        min(for $i in (1 to 4)
        where ($currpage - $i) > 0
        return $currpage - $i)
    let $rangestart := max(($pagemin, 1))
    let $rangeend := min(($total-pages,$rangestart + 4))

    return
      if (empty($start))
      then
        <div class="result-navigation"></div>
      else
        <div class="result-navigation">
            <span class="page"><b>{$start}-{$end}</b> of <b>{$total}</b></span>
                { if ($previous) then <a href="{$previous-href}" class="step previous-step" title="View previous {$length} results">&nbsp;&nbsp;</a> else () }
                <span class="pagination">
                    { for $i in ($rangestart to $rangeend)
                      let $page-start := (($length * $i) + 1) - $length
                      let $page-href := concat("/search?q=",if ($qtext) then encode-for-uri($qtext) else (),"&amp;start=",$page-start)
                      return
                        if ($i eq $currpage)
                        then <span>&nbsp;{$i}&nbsp;&nbsp;&nbsp;</span>
                        else <a href="{$page-href}">&nbsp;{$i}&nbsp;&nbsp;&nbsp;</a>
                    }
                </span>
                { if ($next) then <a href="{$next-href}" class="step next-step" title="View next {$length} results">&nbsp;&nbsp;</a> else () }
        </div>
};

(:~
 : Toggle controls for shorter/longer snippets.
 :)
declare function asc:result-toggle()
as element(div)
{
    let $q := data($config:CONTEXT/*:q)
    let $remove :=
        for $tok in tokenize($q," ")
        return if (matches($tok,"results:")) then $tok else ()
    let $selected :=
        if ($remove)
        then substring-after(($remove)[1],"results:")
        else "compact"
    let $pre :=
        if ($remove)
        then search:remove-constraint($q,($remove)[1],$config:OPTIONS)
        else $q
    return
        <div class="set">
        {
        for $i in $config:OPTIONS/search:operator[@name eq "results"]/search:state/@name/string()
        let $newq := encode-for-uri(concat($pre, " results:",$i))
        let $newurl := concat("/search?q=", $newq)
        return
            <a href="{$newurl}" class="icon {$i} {if ($i eq $selected) then "icon-selected" else ()} " title="Show {$i} results">Show {$i} results</a>
        }
        </div>
};

(:~
 : Search input box.
 :)
declare function asc:searchbox()
as element(form)
{
   <form id="searchform" name="searchform" method="GET" action="/search">
      <input type="text" id="q" name="q" class="searchbox" value="{data($config:CONTEXT/*:q)}"/>
      <div id="suggestions"><!--suggestions here--></div>
      <div id="searchbutton" class="searchbutton">
        <button type="submit" title="Run Search"><img src="/images/mt_icon_search.gif"/></button>
      </div>
    </form>
};

(:~
 : Sidebar.
 :)
declare function asc:sidebar()
as element(div)?
{
    let $view := $config:CONTEXT/*:view
    return
        if ($view = ("help","contact","terms"))
        then ()
        else
        <div class="sidebar" arcsize="5 5 0 0">
            <div class="sidebar-background" arcsize="5 0 0 5" border="rgb(222,222,222)" id="sidebar_background">&nbsp;</div>
            <div class="sidebar-shadow">
                <div>&nbsp;</div></div>
                { if ($view eq "detail")
                  then xdmp:apply($config:remove-facet)
                  else if ($view = ("search","intro"))
                  then xdmp:apply($config:facets)
                  else ()}
        </div>
};
(:~
 : Drop-down sort menu.
 :)
declare function asc:sort-menu()
as element(div)?
{
    if (count($config:OPTIONS/search:operator[@name eq "sort"]/search:state) > 0)
    then
    <div class="menu sort" id="sort_menu_controller" title="Reorder the results">
        <span class="title">SORT</span> <span class="label" id="sort_menu_label">&nbsp;</span> <span class="arrow">&nbsp;</span>
    </div>
    else ()
};

(:~
 : Toolbar containing snippet toggle and sort menu controls.
 :)
declare function asc:toolbar()
as element(div)
{
<div class="toolbar">
    {
    if ($config:CONTEXT/*:view eq "detail")
    then ()
    else
     (
      xdmp:apply($config:result-toggle),
      xdmp:apply($config:sort-menu)
     )
    }
</div>
};

(:~
 : Wrapper for result list presentation.
 :)
declare function asc:results()
as element(div)
{
    <div id="resultlist">
    {
        for $result in $config:RESPONSE/search:result
        return xdmp:apply($config:transform-result, $result)
    }
    </div>
};

(:~
 : Personalized welcome message.
 :)
declare function asc:user()
as element(div)
{
    <div class="user">
        Welcome{
            if (data($config:CONTEXT/*:user) and data($config:CONTEXT/*:user) ne "")
            then concat(", ", data($config:CONTEXT/*:user))
            else ()
            }
    </div>
};

(:~
 : Make a generic chiclet.
 :)
declare function asc:chiclet($href as xs:string, $title as xs:string)
{
     <div class="facet" title="Remove {$title}">
        <a href="{$href}" class="close"><span>&nbsp;</span></a><div class="label" title="{$title}">{$title}</div>
    </div>
};

(:~
 : Emit Doctype declaration.
 :)
declare function asc:doctype()
{
  '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'
};

(:~
 : Create content based on current view.
 :)
declare function asc:get-content()
{
    let $view := $config:CONTEXT/*:view
    return
        if ($view eq "search")
        then (
            xdmp:apply($config:toolbar),
            if (data($config:RESPONSE/@total) eq 0)
            then xdmp:apply($config:error-message, concat("Your search for ",$config:CONTEXT/*:q," did not match anything. Make sure all words are spelled correctly or try different keywords."))
            else (
                xdmp:apply($config:result-navigation),
                xdmp:apply($config:results),
                xdmp:apply($config:result-navigation)))
        else if ($view eq "detail")
        then (
            xdmp:apply($config:toolbar),
            xdmp:apply($config:item-render)  )
        else if ($view eq "terms")
        then xdmp:apply($config:terms)
        else if ($view eq "help")
        then xdmp:apply($config:help)
        else if ($view eq "contact")
        then xdmp:apply($config:contact)
        else xdmp:apply($config:browse)
};

(:~
 : Prepare a facet for chiclet removal.
 :)
declare function asc:facet-chiclet($qtext as xs:string,$options as element(search:options),$facet-name as xs:string)
as element(div)?
{
   let $parsed := search:parse($qtext,$options)
   let $query := xdmp:apply($config:facet-extract,$parsed,$facet-name)
   return
   if ($query and count($query) eq 1) then
       let $quot := string($options/search:grammar/search:quotation)
       let $quot-len := string-length($quot)
       let $text := search:unparse($query)
       let $newquery := search:remove-constraint($qtext,$text,$options)
       let $href := concat("/search?q=",encode-for-uri($newquery))
       let $facet-id := substring-before($facet-name, ":")
       let $facet-val := substring-after($text, $facet-name)
       let $facet-val := if (starts-with($facet-val, $quot))
                         then substring($facet-val, $quot-len + 1)
                         else $facet-val
       let $facet-val := if (ends-with($facet-val, $quot))
                         then substring($facet-val, 1, string-length($facet-val) - $quot-len)
                         else $facet-val
       let $bucket-label := $options/search:constraint[@name eq $facet-id]/search:range/search:bucket[@name eq $facet-val]
       let $title :=
           concat(
               trans:translate($facet-id, $config:LABELS,(),"en"),
               ":",
               if ($bucket-label)
               then string($bucket-label)
               else trans:translate($facet-val, $config:LABELS,(),"en")
               )
       return xdmp:apply($config:chiclet,$href,$title)
   else if ($query and count($query) gt 1)
   then
       let $q := $qtext
       let $newquery :=
           for $i in $query return xdmp:set($q,search:remove-constraint($q,search:unparse($i),$options))
       let $href := concat("/search?q=",encode-for-uri($q))
       let $title := trans:translate(substring-before($facet-name,":"),$config:LABELS,(),"en")
       return xdmp:apply($config:chiclet,$href,$title)
   else ()
};

(:~
 : Extract a facet subquery from a parsed query.
 :)
declare function asc:facet-extract($parsed as element(),$facet-name as xs:string)
as schema-element(cts:query)*
{
    if ($parsed/self::cts:properties-query
        or $parsed/self::cts:element-query
        or $parsed/self::cts:element-attribute-pair-geospatial-query
        or $parsed/self::cts:element-child-geospatial-query
        or $parsed/self::cts:element-geospatial-query
        or $parsed/self::cts:element-pair-geospatial-query)
    then
       () (: Oh, forget it, we don't care about these. Property, element, and geo queries should never produce facets. :)
    else
      if ($parsed[@qtextpre eq $facet-name or contains(@qtextconst,$facet-name)])
      then $parsed
      else for $child in $parsed/* return xdmp:apply($config:facet-extract,$child,$facet-name)
};

(:~
 : Create facet togglers from $options.
 :)
declare function asc:facet-toggle-content($options as element(search:options))
as xs:string
{
    let $opts :=
        for $i in $options/search:constraint[(search:collection|search:range)][not(./*/@facet eq false())]/@name/string()
        return concat('{controller: "view_toggle_',$i,'",list:"all_',$i,'", openTitle:"...More", closedTitle:"...Fewer", isCollapsed:true}')
    return string-join($opts,",&#10;")
};

(:~
 : Error message wrapper.
 :)
declare function asc:error-message($message as xs:string)
as element(div)
{
    <div class="error">
           {$message}
    </div>
};

(:~
 : Null function, used to suppress display of components.
 :)
declare function asc:null()
as empty-sequence()
{
  ()
};

(:~
 : Metadata display for single result.
 :)
declare function asc:result-metadata($result as document-node())
as element(div)
{
  let $params := map:map()
  let $labels := map:put($params,"{http://marklogic.com/appservices/config}LABELS",$config:LABELS)
  let $meta := xdmp:xslt-invoke($config:TRANSFORM-ABSTRACT-METADATA,$result,$params)
  return
  <div class="metadata">{ $meta }</div>
};

(:~
 : Title display for single result.
 :)
declare function asc:result-title($uri as xs:string,$result as document-node())
as element(div)
{
  let $params := map:map()
  let $labels := map:put($params,"{http://marklogic.com/appservices/config}LABELS",$config:LABELS)
  let $title := xdmp:xslt-invoke($config:TRANSFORM-ABSTRACT-TITLE,$result,$params)
  return
  <div class="title">
     <a href="{ concat("/detail",encode-for-uri($uri),"?q=",if ($config:CONTEXT/*:q) then encode-for-uri($config:CONTEXT/*:q) else (),
                       if ($config:CONTEXT/*:start) then concat("&amp;start=", encode-for-uri($config:CONTEXT/*:start)) else ()) }">
         <span class="result-title">{if ($title) then $title else <emphasis>[view item]</emphasis>}</span>
     </a>
  </div>
};

(:~
 : Content for contact page on application.
 :)
declare function asc:contact()
as element(div)
{
    <div class="static contact">
        <h2>Contact Us</h2>
        <p>You should declare app:contact in appfunctions.xqy</p>
    </div>
};

(:~
 : Content for help page on application.
 :)
declare function asc:help()
as element(div)
{
    <div class="static help">
        <h2>Help</h2>
        <p>You should declare app:help in appfunctions.xqy</p>
    </div>
};

(:~
 : Content for terms page on application.
 :)
declare function asc:terms()
as element(div)
{
	<div class="static terms">
		<h2>Terms of Use</h2>
        <p>You should declare app:terms in appfunctions.xqy</p>
	</div>
};

(:~
 : Make the appropriate header for the sidebar.
 :)
declare function asc:sidebar-header($header as xs:string)
as element(div)
{
    <div class="sidebar-header" arcsize="5 0 0 0">
        {$header}
    </div>
};

(:~
 : Get the proper css given a chosen skin
 :)
declare function asc:skin($skin as xs:string)
as element(link)
{
    <link type="text/css" rel="stylesheet" media="screen" href="{ concat('/skins/',$skin,"/",$skin, '.css')  }"/>
};

(:~
 : Create the content for the sort menu from $options
 :)
declare function asc:sort-menu-content($options as element(search:options),$q as xs:string?,$labels as element(label:labels))
as xs:string?
{
    let $opts :=
        for $i in $options/search:operator[@name eq "sort"]/search:state/@name/string()
        let $pre :=
            if (matches($q,"sort:"))
            then (
                let $remove :=
                    for $tok in tokenize($q," ")
                    return if (matches($tok,"sort:")) then $tok else ()
                return search:remove-constraint($q,($remove)[1],$config:OPTIONS))
            else $q
        let $newq := concat($pre, " sort:",$i)
        let $newurl := concat("/search?q=",encode-for-uri($newq))
        return
          concat("{text: '", trans:translate($i,$labels,(),"en") ,"'",", url: '",$newurl,"'}")
    return
        if ($opts) then string-join($opts,",&#10;") else ()
};

(:~
 : Transform a single result.
 :)
declare function asc:transform-result($result as element(search:result))
{
    let $doc:= doc($result/@uri)
    return
      <div class="result" id="{$result/@uri}">
          { xdmp:apply($config:result-title,$result/@uri,$doc)}
          {if ($result/search:snippet)
          then
              <div class="snippet" id="{$result/@uri}-snip">
                  {
                  xdmp:apply($config:transform-snippet,$result/search:snippet)
                  }
              </div>
          else ()}
          { xdmp:apply($config:result-metadata,$doc) }
          { if ($result//search:constraint-meta[@name eq "Rating"])
            then
              <div id="snippet-star" rating="{fn:substring($result//search:constraint-meta[@name eq "Rating"], 1, 1)}"></div>
            else
              <div id="snippet-star" rating="0"></div>
          }
     </div>
};

(:~
 : Transform a snippet to xhtml.
 :)
declare function asc:transform-snippet($snippet as element(search:snippet))
as element(p)
{
    <p class="snippet">
    {
        for $match in $snippet/search:match
        return
          for $node in $match/node()
          return
            typeswitch($node)
              case element(search:highlight)
                return <span class="highlight">{fn:data($node)}</span>
              case text()
                return $node
              default return xs:string($node)
    }
    </p>
};
