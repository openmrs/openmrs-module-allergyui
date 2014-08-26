<%
    ui.decorateWith("appui", "standardEmrPage")
%>

<% ui.includeCss("allergyui", "allergy.css") %>

<script type="text/javascript">
    var breadcrumbs = [
        { icon: "icon-home", link: '/' + OPENMRS_CONTEXT_PATH + '/index.htm' },
        { label: "${ ui.format(patient.familyName) }, ${ ui.format(patient.givenName) }" , link: '${ui.pageLink("coreapps", "clinicianfacing/patient", [patientId: patient.id])}'},
        { label: "${ ui.message("allergyui.addNewAllergy") }" }
    ];

    var patient = { id: ${ patient.id } };

    jq(function() {
        setCategory(0);
    });

     setCategory = function(c) {
        jq(".category").each(function(idx){
            if (idx == c) {
                jq(this).show();
            } else {
                jq(this).hide();
            }
        });
     }

</script>

${ ui.includeFragment("coreapps", "patientHeader", [ patient: patient ]) }

<h2>
	${ ui.message("allergyui.addNewAllergy") }
</h2>

<form method="post" id="allergy" action="${ ui.pageLink("allergyui", "allergy", [patientId: patient.id]) }">
    <div id="types" class="horizontal inputs">
        <label>${ ui.message("allergyui.categories") }:</label>
        <% allergenTypes.eachWithIndex { category, idx -> %>
            <div><input type="radio" name="category" onClick="setCategory(${ idx })" ${ if(idx == 0) "checked=checked" }>${ category }</div>
        <% } %>
    </div>
    <div class="horizontal tabs">
        <div id="allergens" class="tab">
            <label>${ ui.message("allergyui.allergen") }:</label>
            <div class="category">
                <% drugAllergens.each { allergen -> %>
                    <div><input type="radio" name="allergenId" value="${allergen.id}">${allergen.name}</div>
                <% } %>
            </div>
            <div class="category">
                <% foodAllergens.each { allergen -> %>
                    <div><input type="radio" name="allergenId" value="${allergen.id}">${allergen.name}</div>
                <% } %>
            </div>
            <div class="category">
                <% enviromentalAllergens.each { allergen -> %>
                    <div><input type="radio" name="allergenId" value="${allergen.id}">${allergen.name}</div>
                <% } %>
            </div>
        </div>
        <div id="reactions" class="tabs tab">
            <label>${ ui.message("allergyui.reactions") }:</label>
            <% allergyReactions.each { reaction -> %>
                <div><input type="checkbox" name="reactions" value="${reaction.id}">${reaction.name}</div>
            <% } %>
        </div>
    </div>
    <div id="severities" class="horizontal inputs">
        <label>${ ui.message("allergyui.severity") }:</label>
        <% severities.each { severity -> %>
            <div><input type="radio" name="severityId" value="${severity.id}">${severity.name}</div>
        <% } %>
    </div>
    <div id="comment" class="horizontal inputs">
        <label>${ ui.message("allergyui.comment") }:</label>
        <input type="text" name="comment"/>
    </div>
    <div id="actions" class="right">
        <input type="submit" id="addAllergyBtn" class="confirm" value="${ ui.message("allergyui.save") }" />
        <input type="button" class="cancel" value="${ ui.message("allergyui.cancel") }"
         onclick="javascript:window.location='${ ui.pageLink("allergyui", "allergies", [patientId: patient.id]) }'" />
    </div>
</form>