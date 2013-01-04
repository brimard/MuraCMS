<cfset controller = variables.getController() /><cfoutput><c:doctype /><c:html>	<head>		<c:content_type />		<title>ColdMVC/Hyrule Sample Application</title>	    <c:script name="http://html5shim.googlecode.com/svn/trunk/html5.js" condition="lt IE 9" />		<c:style name="bootstrap.min.css" />		<c:style name="stylesheet.css" />		<c:script name="https://ajax.googleapis.com/ajax/libs/jquery/1.6.1/jquery.min.js" />		<c:script name="jquery.tablesorter.min.js" />		<c:script name="app.js" />	</head>	<c:body>		<div class="container">			<div class="content">				<div class="row">					<div id="header" class="span12">						<h1>Hyrule Catalog</h1>						<ul class="nav nav-tabs">							<li class="<cfif controller eq 'index'>active</cfif>"><a href="#linkTo({controller='index'})#">Home</a></li>							<li class="<cfif controller eq 'category'>active</cfif>"><a href="#linkTo({controller='category',action='list'})#">Categories</a></li>							<li class="<cfif controller eq 'product'>active</cfif>"><a href="#linkTo({controller='product',action='list'})#">Products</a></li>						</ul>					</div>				</div>				<div class="row">					<div class="span12">						<c:render />					</div>				</div>			</div>		</div>	</c:body></c:html></cfoutput>