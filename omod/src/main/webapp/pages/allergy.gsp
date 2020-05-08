<%
    ui.decorateWith("appui", "standardEmrPage")
    ui.includeJavascript("uicommons", "angular.min.js")
    ui.includeJavascript("uicommons", "angular-ui/ui-bootstrap-tpls-0.11.2.min.js")
	ui.includeJavascript("allergyui", "allergy.js")
    ui.includeJavascript("uicommons", "angular-resource.min.js")
    ui.includeJavascript("uicommons", "angular-common.js")
    ui.includeJavascript("uicommons", "ngDialog/ngDialog.js")
    ui.includeJavascript("uicommons", "ngDialog/ngDialog.js")
    ui.includeJavascript("uicommons", "services/conceptSearchService.js")
    ui.includeJavascript("uicommons", "directives/coded-or-free-text-answer.js")
    ui.includeCss("uicommons", "ngDialog/ngDialog.min.css")

    ui.includeCss("allergyui", "allergy.css")
    def isEdit = allergy.id != null;
    def title = isEdit ?
            ui.message("allergyui.editAllergy", ui.escapeJs(ui.encodeHtmlContent(ui.format(allergy.allergen.coded ? allergy.allergen.codedAllergen : allergy.allergen)))) :
            ui.message("allergyui.addNewAllergy");

    def allergensByType = [
        DRUG: drugAllergens,
        FOOD: foodAllergens,
        OTHER: otherAllergens
    ]
%>
<script type="text/javascript">
    var breadcrumbs = [
        { icon: "icon-home", link: '/' + OPENMRS_CONTEXT_PATH + '/index.htm' },
        { label: "${ ui.escapeJs(ui.encodeHtmlContent(ui.format(patient.familyName))) }, ${ ui.escapeJs(ui.encodeHtmlContent(ui.format(patient.givenName))) }" , link: '${ui.pageLink("coreapps", "clinicianfacing/patient", [patientId: patient.id])}'},
        { label: "${ ui.message("allergyui.allergies") }", link: '${ui.pageLink("allergyui", "allergies", [patientId: patient.id, returnUrl: returnUrl])}'},
        { label: "${ title }" }
    ];
    
</script>

${ ui.includeFragment("coreapps", "patientHeader", [ patient: patient ]) }

${ ui.includeFragment("allergyui", "removeAllergyDialog") }

<% ui.includeJavascript("allergyui", "allergies.js") %>

<div id="allergy" ng-app="allergyApp" ng-controller="allergyController" ng-init="severity = ${ allergy?.severity?.id }; allergenType='${allergy.allergen == null ? "DRUG" : allergy.allergen.allergenType}'; otherConceptId=${otherNonCodedConcept.conceptId}">

    <h2 class="inline">${ title }</h2>

    <% if (isEdit) { %>
        <button type="button" class="cancel inline right" onclick="removeAllergy('${ ui.encodeJavaScriptAttribute(ui.format(allergy.allergen)) }', ${ allergy.id})">
             ${ ui.message("allergyui.removeAllergy") }
        </button>
    <% } %>

	<form method="post" id="allergy" action="${ ui.pageLink("allergyui", "allergy", [patientId: patient.id, returnUrl: returnUrl]) }">

        <input type="hidden" name="allergenType" value="{{allergenType}}"/>
        <% if (isEdit) { %>
            <input type="hidden" name="allergyId" value="${allergy.id}" />
        <% } %>

        <% if (!isEdit) { %>
            <div id="allergens">
                <div id="types" class="button-group horizontal">
                    <% allergenTypes.each { category ->  if (category.name()!="ENVIRONMENT") { %>
                    <label class="button small" ng-model="allergenType" btn-radio="'${ui.format(category)}'" ng-class="{ confirm: allergenType == '${ui.format(category)}' }">
                        ${ category }
                    </label>
                    <% } } %>
                </div>
                <% allergensByType.each {
                    def typeName = it.key
                    def allergens = it.value
                %>
                    <ul ng-show="allergenType == '${ typeName }'">
                        <% allergens.each { allergen -> %>
                        <li>
                            <% if (allergen.id == otherNonCodedConcept.id) { %>
                                <input id="allergen-${allergen.id}" type="radio" name="codedAllergen" value="${allergen.id}" class="coded_allergens" ng-model="allergen" ng-click="checkOtherRadioButton()"
                                    ${(allergy.allergen != null && allergen == allergy.allergen.codedAllergen) ? "checked=checked" : ""}/>
                            <% } else { %>
                                <input id="allergen-${allergen.id}" type="radio" name="codedAllergen" value="${allergen.id}" class="coded_allergens" ng-model="allergen"
                                    ${(allergy.allergen != null && allergen == allergy.allergen.codedAllergen) ? "checked=checked" : ""}/>
                            <% } %>
                            <label for="allergen-${allergen.id}" id="allergen-${allergen.id}-label" class="coded_allergens_label" ng-click="otherFieldFocus()">${ui.format(allergen)}</label>

                            <% if (allergen.id == otherNonCodedConcept.id) { %>
                                <% if(typeName == 'DRUG') { %>
                                    <input type="hidden" name="otherCodedAllergen" ng-value="otherCodedAllergen.concept ? 'CONCEPT:'+otherCodedAllergen.concept.uuid : 'NON_CODED:'+otherCodedAllergen.word">
                                    <coded-or-free-text-answer id="${typeName}otherCodedAllergen" concept-classes="8d490dfc-c2cc-11de-8d13-0010c6dffd0f,b4535251-9183-4175-959e-9ee67dc71e78" ng-model="otherCodedAllergen" ng-click="otherFieldFocus()" />
                                <% } else {%>
                            	    <input type="text" maxlength="255" id="${typeName}nonCodedAllergen" name="nonCodedAllergen" ng-model="nonCodedAllergen" ng-focus="otherFieldFocus()"/>
                                <% } %>
                            <% } %>
                        </li>
                        <% } %>
                    </ul>
                <% } %>
            </div>
        <% } %>

        <div id="reactions">
            <label class="heading">${ ui.message("allergyui.reactionSelection") }:</label>
            <ul>
            <% reactionConcepts.each { reaction -> %>
                <li>
                    <input ng-model="reaction${reaction.id}" type="checkbox" id="reaction-${reaction.id}" class="allergy-reaction" name="allergyReactionConcepts" value="${reaction.id}" ng-init="reaction${reaction.id} = ${ allergyReactionConcepts.contains(reaction) }" />
                    <label for="reaction-${reaction.id}">${ui.format(reaction)}</label>
                    <% if (reaction.id == otherNonCodedConcept.id) { %>
                    	<input type="text" maxlength="255" name="reactionNonCoded" ng-focus="otherReactionFocus(${reaction.id})" <% if (allergy.reactionNonCoded) { %> value="${allergy.reactionNonCoded}" <% } %>/>
                    <% } %>
                </li>
            <% } %>
            </ul>
        </div>

	    <div id="severities" class="horizontal">
	        <label class="heading">${ ui.message("allergyui.severity") }:</label>
	        <% severities.each { severity -> %>
	            <p>
                    <input type="radio" id="severity-${severity.id}" class="allergy-severity" name="severity" value="${severity.id}" ${ severity == allergy.severity ? "checked=checked" : "" } ng-checked="severity == ${severity.id}" ng-model="severity"/>
                    <label for="severity-${severity.id}">${ui.format(severity)}</label>
                </p>
	        <% } %>
	        <i class="icon-remove delete-item" title="${ ui.message("general.clear") }" ng-click="severity = null"></i>
	    </div>

	    <div id="comment">
	        <label>${ ui.message("allergyui.comment") }:</label>
	        <textarea id="allergy-comment" maxlength="1024" name="comment">${allergy.comment != null ? ui.encodeHtmlContent(allergy.comment) : ""}</textarea>
	    </div>

	    <div id="actions">
	        <input type="submit" id="addAllergyBtn" class="confirm right" value="${ ui.message("coreapps.save") }" <% if(!isEdit){ %> ng-disabled="!canSave()" <% } %>/>
	        <input type="button" class="cancel" value="${ ui.message("coreapps.cancel") }"
	         onclick="location.href='${ ui.pageLink("allergyui", "allergies", [patientId: patient.id, returnUrl: returnUrl ]) }'" />
	    </div>
	</form>
</div>
