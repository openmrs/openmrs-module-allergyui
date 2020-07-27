<%
    ui.decorateWith("appui", "standardEmrPage")
    
    ui.includeCss("allergyui", "allergies.css")
%>
<script type="text/javascript">
    var breadcrumbs = [
        { icon: "icon-home", link: '/' + OPENMRS_CONTEXT_PATH + '/index.htm' },
        { label: "${ ui.escapeJs(ui.encodeHtmlContent(ui.format(patient.familyName))) }, ${ ui.escapeJs(ui.encodeHtmlContent(ui.format(patient.givenName))) }" , link: '${ui.pageLink("coreapps", "clinicianfacing/patient", [patientId: patient.id])}'},
        { label: "${ ui.message("allergyui.allergies") }" }
    ];
</script>

<% if(includeFragments){
    includeFragments.each{ %>
        ${ ui.includeFragment(it.extensionParams.provider, it.extensionParams.fragment, [ patient: patient])}
<%   }
} %>


${ ui.includeFragment("coreapps", "patientHeader", [ patient: patient ]) }

${ ui.includeFragment("allergyui", "removeAllergyDialog") }

<% 
    ui.includeJavascript("allergyui", "allergies.js") 
    ui.includeJavascript("appui", "jquery-3.4.1.min.js")
%>


${ ui.includeFragment("uicommons", "infoAndErrorMessage")}
<h2>
	${ ui.message("allergyui.allergies") }
</h2>

<table id="allergies" class="allergies" width="100%" border="1" cellspacing="0" cellpadding="2">
    <thead>
	    <tr>
	        <th>${ ui.message("allergyui.allergen") }</th>
	        <th>${ ui.message("allergyui.reaction") }</th>
	        <th>${ ui.message("allergyui.severity") }</th>
	        <th>${ ui.message("allergyui.comment") }</th>
	        <th>${ ui.message("allergyui.lastUpdated") }</th>
	        
	        <% if (hasModifyAllergiesPrivilege) { %>
	        	<th>${ ui.message("coreapps.actions") }</th>
	        <% } %>
	    </tr>
    </thead>
    
    <tbody>
    	<% if (allergies.size() == 0) { %>
            <tr>
                <td colspan="6" align="center" class="allergyStatus">
                <% if (allergies.allergyStatus != "No known allergies") { %>
                    <% if (allergies.allergyStatus == "Unknown") { %>
                        ${ ui.message("allergyui.unknown") }
                    <% } else { %>
                        ${ ui.message(allergies.allergyStatus) }
                    <% } %>
                <% } else { %>
                    <form name="deactivateForm" method="POST">
                        ${ ui.message("allergyui.noKnownAllergies") }
                        <input type="hidden" name="patientId" value="${patient.id}"/>
                        <input type="hidden" name="action" value="deactivate"/>
                        <i class="icon-remove small delete-action" onclick="document.deactivateForm.submit();"/>
                     </form>
                <% } %>
                </td>
            </tr>
        <% } %>
        
        <% allergies.each { allergy -> %>
            <tr>
                <td class="allergen" <% if (hasModifyAllergiesPrivilege) { %> onclick="location.href='${ ui.pageLink("allergyui", "allergy", [allergyId:allergy.id, patientId: patient.id, returnUrl: returnUrl]) }'" <% } %> >
                	<% if (!allergy.allergen.coded) { %>"<% } %>${ ui.encodeHtmlContent(ui.format(allergy.allergen.coded ? allergy.allergen.codedAllergen : allergy.allergen)) }<% if (!allergy.allergen.coded) { %>"<% } %> 
                </td>
                
                <td class="reaction" <% if (hasModifyAllergiesPrivilege) { %> onclick="location.href='${ ui.pageLink("allergyui", "allergy", [allergyId:allergy.id, patientId: patient.id, returnUrl: returnUrl]) }'" <% } %> >
                	<% allergy.reactions.eachWithIndex { reaction, index -> %><% if (index > 0) { %>,<% } %> ${ui.encodeHtmlContent(ui.format(reaction.reactionNonCoded ? reaction : reaction.reaction))}<% } %>
                </td>
                
                <td <% if (hasModifyAllergiesPrivilege) { %> onclick="location.href='${ ui.pageLink("allergyui", "allergy", [allergyId:allergy.id, patientId: patient.id, returnUrl: returnUrl]) }'" <% } %> >
                	<% if (allergy.severity) { %> ${ ui.encodeHtmlContent(ui.format(allergy.severity.name)) } <% } %> 
                </td>
                
                <td <% if (hasModifyAllergiesPrivilege) { %> onclick="location.href='${ ui.pageLink("allergyui", "allergy", [allergyId:allergy.id, patientId: patient.id, returnUrl: returnUrl]) }'" <% } %> >
                	${ ui.encodeHtmlContent(allergy.comment) } 
                </td>
                <td <% if (hasModifyAllergiesPrivilege) { %> onclick="location.href='${ ui.pageLink("allergyui", "allergy", [allergyId:allergy.id, patientId: patient.id, returnUrl: returnUrl]) }'" <% } %> >
                	${ ui.formatDatetimePretty(allergy.dateLastUpdated) } 
                </td>
                
                <% if (hasModifyAllergiesPrivilege) { %>
	                <td>
	                	<i class="icon-pencil edit-action" title="${ ui.message("coreapps.edit") }"
	                       onclick="location.href='${ ui.pageLink("allergyui", "allergy", [allergyId:allergy.id, patientId: patient.id, returnUrl: returnUrl]) }'"></i>
	                    <i class="icon-remove delete-action" title="${ ui.message("coreapps.delete") }" onclick="removeAllergy('${ ui.encodeJavaScriptAttribute(ui.format(allergy.allergen)) }', ${ allergy.id})"></i>
	                </td>
                <% } %>
            </tr>
        <% } %>
    </tbody>
</table>

<br/>

<% if (hasModifyAllergiesPrivilege) { %>
    <button class="cancel" onclick="location.href='${ ui.encodeHtml(returnUrl) }'">
        ${ ui.message("uicommons.return") }
    </button>
	<button id ="allergyui-addNewAllergy" class="confirm right" onclick="location.href='${ ui.pageLink("allergyui", "allergy", [patientId: patient.id, returnUrl: returnUrl]) }'">
	    ${ ui.message("allergyui.addNewAllergy") }
	</button>

	<form method="POST" action="${ ui.pageLink("allergyui", "allergies") }">
	    <input type="hidden" name="patientId" value="${patient.id}"/>
        <input type="hidden" name="returnUrl" value="${ ui.encodeHtml(returnUrl) }"/>
	    <input type="hidden" name="action" value="confirmNoKnownAllergies"/>
		<button type="submit" class="confirm right" style="<% if (allergies.allergyStatus != "Unknown") { %> display:none; <% } %>">
		    ${ ui.message("allergyui.noKnownAllergy") }
		</button>
	</form>
<% } %>
