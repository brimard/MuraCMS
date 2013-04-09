<!--- This file is part of Mura CMS.

Mura CMS is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, Version 2 of the License.

Mura CMS is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Mura CMS. If not, see <http://www.gnu.org/licenses/>.

Linking Mura CMS statically or dynamically with other modules constitutes the preparation of a derivative work based on 
Mura CMS. Thus, the terms and conditions of the GNU General Public License version 2 ("GPL") cover the entire combined work.

However, as a special exception, the copyright holders of Mura CMS grant you permission to combine Mura CMS with programs
or libraries that are released under the GNU Lesser General Public License version 2.1.

In addition, as a special exception, the copyright holders of Mura CMS grant you permission to combine Mura CMS with 
independent software modules (plugins, themes and bundles), and to distribute these plugins, themes and bundles without 
Mura CMS under the license of your choice, provided that you follow these specific guidelines: 

Your custom code 

• Must not alter any default objects in the Mura CMS database and
• May not alter the default display of the Mura CMS logo within Mura CMS and
• Must not alter any files in the following directories.

 /admin/
 /tasks/
 /config/
 /requirements/mura/
 /Application.cfc
 /index.cfm
 /MuraProxy.cfc

You may copy and distribute Mura CMS with a plug-in, theme or bundle that meets the above guidelines as a combined work 
under the terms of GPL for Mura CMS, provided that you include the source code of that other code when and as the GNU GPL 
requires distribution of source code.

For clarity, if you create a modified version of Mura CMS, you are not obligated to grant this special exception for your 
modified version; it is your choice whether to do so, or to make such modified version available under the GNU General Public License 
version 2 without this exception.  You may, if you choose, apply this exception to your own modified versions of Mura CMS.
--->
<cfcomponent extends="mura.cfobject" output="false">

<cffunction name="init" returntype="any" output="false" access="public">
<cfargument name="configBean" type="any" required="yes"/>
		<cfset variables.instance.configBean=arguments.configBean />
	<cfreturn this />
</cffunction>

<cffunction name="getReminders" returntype="query" output="false" access="public">
<cfargument name="theTime" default="#now()#" required="yes">
<cfset var rs=""/>

<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rs')#">
select tsettings.site,tsettings.contact,tsettings.mailserverIP,tsettings.mailserverUsername,
tsettings.domain ,tsettings.contactName,
tsettings.contactAddress,tsettings.contactCity,tsettings.contactState,tsettings.contactZip,
tsettings.contactEmail,tsettings.contactPhone,tsettings.mailserverPassword,
tcontenteventreminders.email,tcontenteventreminders.remindDate,tcontenteventreminders.remindHour,
tcontenteventreminders.remindMinute,tcontenteventreminders.remindInterval,tcontenteventreminders.contentID,tcontenteventreminders.isSent,
tcontent.siteid,tcontent.title,tcontent.filename,tcontent.summary,tcontent.type,tcontent.parentid,
tcontent.displaystart,tcontent.displaystop 
from tcontenteventreminders inner join tcontent 
On (tcontenteventreminders.contentid=tcontent.contentid and tcontenteventreminders.siteid=tcontent.siteid)
inner join tsettings on (tcontent.siteid=tsettings.siteid)
where
tcontent.display=2
and tcontent.active=1
and tcontenteventreminders.remindDate<=<cfqueryparam cfsqltype="cf_sql_timestamp" value="#LSDateFormat(theTime,'mm/dd/yyyy')#">
and tcontenteventreminders.remindHour<=#hour(theTime)#
and tcontenteventreminders.remindMinute<=#minute(theTime)#
and isSent=0
</cfquery>


<cfreturn rs />
</cffunction>

<cffunction name="getRemindersByContentID" returntype="query" output="false" access="public">
<cfargument name="contentid" type="string"/>
<cfargument name="siteid" type="string"/>
<cfset var rs=""/>

<cfquery name="rs" datasource="#variables.instance.configBean.getReadOnlyDatasource()#"  username="#variables.instance.configBean.getReadOnlyDbUsername()#" password="#variables.instance.configBean.getReadOnlyDbPassword()#">
select * from tcontenteventreminders where contentid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.contentID#"/> and siteid= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteID#"/>
</cfquery>

<cfreturn rs />
</cffunction>

</cfcomponent>