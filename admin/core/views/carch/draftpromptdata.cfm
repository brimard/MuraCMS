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

<cfset draftprompdata=application.contentManager.getDraftPromptData(rc.contentid,rc.siteid)>
<cfif draftprompdata.showdialog>
	<cfset draftprompdata.showdialog='true'>
	<cfsavecontent variable="draftprompdata.message">
	<cfoutput>
		<div id="draft-prompt">
		<p class="alert alert-info">#application.rbFactory.getKeyValue(session.rb,'sitemanager.draftprompt.dialog')#</p>
			
			<cfset publishedVersion=$.getBean('content').loadBy(contenthistid=draftprompdata.publishedHistoryID)>
			<cfif publishedVersion.getApproved()>		
				<table>
					<thead>
						<tr>
							<th colspan="4">#HTMLEditFormat(application.rbFactory.getKeyValue(session.rb,'sitemanager.draftprompt.published'))#</th>
						</tr>
					</thead>
					<tbody>
						<td><a href="##" tabindex="-1" class="draft-prompt-option" data-contenthistid="#draftprompdata.publishedHistoryID#">#HTMLEditFormat(publishedVersion.getMenuTitle())#</a></td>
						<td>#LSDateFormat(publishedVersion.getlastupdate(),session.dateKeyFormat)# #LSTimeFormat(publishedVersion.getLastUpdate(),"medium")#</td>
						<td>#HTMLEditFormat(publishedVersion.getLastUpdateBy())#</td>
						<td><a href="##" tabindex="-1" class="draft-prompt-option" data-contenthistid="#draftprompdata.publishedHistoryID#"><i class="icon-pencil"></i></a></td>
					</tbody>
				</table>
			</cfif>

			<cfif draftprompdata.hasdraft>

				<cfset draftVersion=$.getBean('content').loadBy(contenthistid=draftprompdata.historyid)>
				<table>
					<thead>
						<tr>
							<th colspan="4">#HTMLEditFormat(application.rbFactory.getKeyValue(session.rb,'sitemanager.draftprompt.latest'))#</th>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td><a href="##" tabindex="-1" class="draft-prompt-option" data-contenthistid="#draftprompdata.historyid#">#HTMLEditFormat(draftVersion.getMenuTitle())#</a></td>
							<td>#LSDateFormat(draftVersion.getlastupdate(),session.dateKeyFormat)# #LSTimeFormat(draftVersion.getLastUpdate(),"medium")#</td>
							<td>#HTMLEditFormat(draftVersion.getLastUpdateBy())#</td>
							<td><a href="##" tabindex="-1" class="draft-prompt-option" data-contenthistid="#draftprompdata.historyid#"><i class="icon-pencil"></i></a></td>
						</tr>
					</tbody>
				</table>
			</cfif>

			<cfif draftprompdata.pendingchangesets.recordcount>
				<table>	
					<thead>
						<tr>
							<th colspan="4">#HTMLEditFormat(application.rbFactory.getKeyValue(session.rb,'sitemanager.draftprompt.changesets'))#</th>
						</tr>
					</thead>
					<tbody>
						<cfloop query="draftprompdata.pendingchangesets">
						<tr>
							<td><a href="##" tabindex="-1" class="draft-prompt-option" data-contenthistid="#draftprompdata.pendingchangesets.contenthistid#">#HTMLEditFormat(draftprompdata.pendingchangesets.changesetName)#</a></td>
							<td>#LSDateFormat(draftprompdata.pendingchangesets.lastupdate,session.dateKeyFormat)# #LSTimeFormat(draftprompdata.pendingchangesets.lastupdate,"medium")#</td>
							<td>#HTMLEditFormat(draftprompdata.pendingchangesets.lastupdateby)#</td>
							<td><a href="##" tabindex="-1" class="draft-prompt-option" data-contenthistid="#draftprompdata.pendingchangesets.contenthistid#"><i class="icon-pencil"></i></a></td>
						</tr>
						</cfloop>
					</tbody>
				</table>
			</cfif>

			<cfif draftprompdata.yourapprovals.recordcount>
				<cfset content=$.getBean('content').loadBy(contentid=rc.contentid)>
				<table>	
					<thead>
						<tr>
							<th colspan="4">#HTMLEditFormat(application.rbFactory.getKeyValue(session.rb,'sitemanager.draftprompt.awaitingapprovals'))#</th>
						</tr>
					</thead>
					<tbody>
						<cfloop query="draftprompdata.yourapprovals">
							<tr>
								<td><a href="#content.getURL(querystring="previewid=#draftprompdata.yourapprovals.contenthistid#")#" tabindex="-1" class="draft-prompt-approval">#HTMLEditFormat(draftprompdata.yourapprovals.menutitle)#</a></td>
								<td>#LSDateFormat(draftprompdata.yourapprovals.lastupdate,session.dateKeyFormat)# #LSTimeFormat(draftprompdata.yourapprovals.lastupdate,"medium")#</td>
								<td>#HTMLEditFormat(draftprompdata.yourapprovals.lastupdateby)#</td>
								<td><a href="#content.getURL(querystring="previewid=#draftprompdata.yourapprovals.contenthistid#")#" tabindex="-1" class="draft-prompt-approval"><i class="icon-pencil"></i></a></td>
							</tr>
						</cfloop>
					</tbody>
				</table>
			</cfif>
					
		<!---			
		<cfif listFindNoCase('Pending,Rejected',draftprompdata.pendingchangesets.approvalStatus)>
							(#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.#draftprompdata.pendingchangesets.approvalStatus#')#)
						</cfif>
		--->
		
		
	
		</div>
	</cfoutput>
	</cfsavecontent>
<cfelse>
	<cfset draftprompdata.showdialog='false'>
	<cfset draftprompdata.message="">	
</cfif>
<cfset structDelete(draftprompdata,'yourapprovals')>
<cfset structDelete(draftprompdata,'pendingchangesets')>
<cfcontent type="application/json">
<cfoutput>#createObject("component","mura.json").encode(draftprompdata)#</cfoutput>
<cfabort>