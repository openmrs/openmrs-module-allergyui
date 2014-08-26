<%
    ui.decorateWith("appui", "standardEmrPage")
%>
<script type="text/javascript">
    var breadcrumbs = [
        { icon: "icon-home", link: '/' + OPENMRS_CONTEXT_PATH + '/index.htm' },
        { label: "${ ui.format(patient.familyName) }, ${ ui.format(patient.givenName) }" , link: '${ui.pageLink("coreapps", "clinicianfacing/patient", [patientId: patient.id])}'},
        { label: "${ ui.message("allergyui.allergies") }" }
    ];
    
    var patient = { id: ${ patient.id } };
</script>

${ ui.includeFragment("coreapps", "patientHeader", [ patient: patient ]) }

<h2>
	${ ui.message("allergyui.allergies") }
</h2>

<table id="allergies" width="100%" border="1" cellspacing="0" cellpadding="2">
    <thead>
	    <tr>
	        <th>${ ui.message("allergyui.allergen") }</th>
	        <th>${ ui.message("allergyui.reaction") }</th>
	        <th>${ ui.message("allergyui.severity") }</th>
	        <th>${ ui.message("allergyui.comment") }</th>
	        <th>${ ui.message("allergyui.lastUpdated") }</th>
	    </tr>
    </thead>
    
    <tbody>
    </tbody>
</table>

<div id="actions" class="right">
    <button id="addAlergy" onclick="location.href='${ui.pageLink("allergyui", "allergy", [patientId: patient.id])}'">${ ui.message("allergyui.addNewAllergy") }</button>
    <button id="noKnownAllergy">${ ui.message("allergyui.noKnownAllergy") }</button>
</div>