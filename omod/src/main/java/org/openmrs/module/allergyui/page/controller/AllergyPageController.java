/**
 * The contents of this file are subject to the OpenMRS Public License
 * Version 1.0 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://license.openmrs.org
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 * Copyright (C) OpenMRS, LLC.  All Rights Reserved.
 */
/**
 * The contents of this file are subject to the OpenMRS Public License
 * Version 1.0 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://license.openmrs.org
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 * Copyright (C) OpenMRS, LLC.  All Rights Reserved.
 */
package org.openmrs.module.allergyui.page.controller;

import org.openmrs.Concept;
import org.openmrs.Patient;
import org.openmrs.api.ConceptService;
import org.openmrs.module.allergyapi.*;
import org.openmrs.module.allergyapi.api.PatientService;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.annotation.MethodParam;
import org.openmrs.ui.framework.annotation.SpringBean;
import org.openmrs.ui.framework.fragment.action.SuccessResult;
import org.openmrs.ui.framework.page.PageModel;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpServletRequest;
import java.util.List;

public class AllergyPageController {

    public void controller(PageModel model, @RequestParam("patientId") Patient patient, UiUtils ui,
                           @SpringBean("allergyService") PatientService patientService,
                           @SpringBean("conceptService") ConceptService conceptService) {
        model.addAttribute("patient", patient);
        model.addAttribute("allergenTypes", AllergenType.values());
        model.addAttribute("enviromentalAllergens", conceptService.getConceptsByConceptSet(conceptService.getConceptByName("Reference application common environmental allergens")));
        model.addAttribute("foodAllergens", conceptService.getConceptsByConceptSet(conceptService.getConceptByName("Reference application common food allergens")));
        model.addAttribute("drugAllergens", conceptService.getConceptsByConceptSet(conceptService.getConceptByName("Reference application common drug allergens")));
        model.addAttribute("allergyReactions", conceptService.getConceptsByConceptSet(conceptService.getConceptByName("Reference application allergic reactions")));
        model.addAttribute("severities", conceptService.getConceptsByConceptSet(conceptService.getConceptByName("Severities")));
    }

    @Transactional
    public String post(@RequestParam("patientId") Patient patient,
                       @MethodParam("buildAllergen") Allergen allergen,
                       @RequestParam("severityId") Concept severity,
                       @RequestParam("comment") String comment,
                       @RequestParam("reactions") List<AllergyReaction> allergyReactions,
                       @SpringBean("allergyService") PatientService patientService,
                       HttpServletRequest request, PageModel model, UiUtils ui) {
        Allergy allergy = new Allergy(patient, allergen, severity, comment, allergyReactions);
        Allergies allergies = patientService.getAllergies(patient);
        allergies.add(allergy);
        Allergies savedAllergies = patientService.setAllergies(patient, allergies);
        return new SuccessResult(ui.message("allergyui.addNewAllergy.success")).toString();
    }

    public Allergen buildAllergen(@RequestParam("allergenId") String allergenId) {
        return new Allergen();
    }
}
