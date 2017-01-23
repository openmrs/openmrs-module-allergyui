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

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.openmrs.Allergen;
import org.openmrs.AllergenType;
import org.openmrs.Allergies;
import org.openmrs.Allergy;
import org.openmrs.AllergyProperties;
import org.openmrs.AllergyReaction;
import org.openmrs.Concept;
import org.openmrs.Patient;
import org.openmrs.api.PatientService;
import org.openmrs.api.context.Context;
import org.openmrs.messagesource.MessageSourceService;
import org.openmrs.module.uicommons.UiCommonsConstants;
import org.openmrs.module.uicommons.util.InfoErrorMessageUtil;
import org.openmrs.ui.framework.CodedOrFreeTextValue;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.annotation.BindParams;
import org.openmrs.ui.framework.annotation.MethodParam;
import org.openmrs.ui.framework.annotation.SpringBean;
import org.openmrs.ui.framework.page.PageModel;
import org.openmrs.ui.util.ByFormattedObjectComparator;
import org.openmrs.validator.AllergyValidator;
import org.springframework.validation.BeanPropertyBindingResult;
import org.springframework.validation.Errors;
import org.springframework.validation.ObjectError;
import org.springframework.web.bind.annotation.RequestParam;

public class AllergyPageController {
	
	public void controller(PageModel model, @RequestParam(value = "allergyId", required = false) Integer allergyId,
	                       @RequestParam("patientId") Patient patient,
                           @RequestParam(value = "returnUrl", required = false) String returnUrl, UiUtils ui,
	                       @SpringBean("patientService") PatientService patientService,
	                       @SpringBean("allergyProperties") AllergyProperties properties) {
		
		Allergy allergy;
		if (allergyId == null) {
			allergy = new Allergy(patient, null, null, null, null);
		} else {
			allergy = patientService.getAllergies(patient).getAllergy(allergyId);
		}
		
		setModelAttributes(allergy, returnUrl, model, properties, ui);
	}
	
	public String post(@MethodParam("getAllergy") @BindParams Allergy allergy, @RequestParam("patientId") Patient patient,
                       @RequestParam(value = "returnUrl", required = false) String returnUrl,
	                   PageModel model, @SpringBean("patientService") PatientService patientService,
	                   @SpringBean("allergyProperties") AllergyProperties properties,
	                   @SpringBean("messageSourceService") MessageSourceService messageService,
	                   @SpringBean("allergyValidator") AllergyValidator validator, HttpSession session, UiUtils ui)
	    throws Exception {
		
		Errors errors = new BeanPropertyBindingResult(allergy, "allergy");
		validator.validate(allergy, errors);
		
		if (errors.hasErrors()) {
			addModelErrors(model, errors, session, messageService);
		} else {
			Allergies allergies = patientService.getAllergies(patient);
			String successMsgCode = "allergyui.message.success";
			
			if (allergy.getAllergyId() == null) {
				if (allergies.containsAllergen(allergy)) {
					String errorMessage = messageService.getMessage("allergyui.message.duplicateAllergen",
					    new Object[] { allergy.getAllergen().toString() }, Context.getLocale());
					session.setAttribute(UiCommonsConstants.SESSION_ATTRIBUTE_ERROR_MESSAGE, errorMessage);
					return "redirect:allergyui/allergy.page?patientId=" + patient.getPatientId();
				}
				allergies.add(allergy);
				successMsgCode = "allergyui.addNewAllergy.success";
			}
			
			try {
				patientService.setAllergies(patient, allergies);
				InfoErrorMessageUtil.flashInfoMessage(session, successMsgCode);
				
				return "redirect:allergyui/allergies.page?patientId=" + patient.getPatientId() + "&returnUrl=" + ui.urlEncode(returnUrl);
			}
			catch (Exception e) {
				session.setAttribute(UiCommonsConstants.SESSION_ATTRIBUTE_ERROR_MESSAGE, "allergyui.message.fail");
			}
		}
		
		setModelAttributes(allergy, returnUrl, model, properties, ui);
		
		return null;
	}
	
	public Allergy getAllergy(@RequestParam(value = "allergyId", required = false) Integer allergyId,
	                          @RequestParam("patientId") Patient patient,
	                          @BindParams Allergen allergen,
	                          @RequestParam(value = "codedAllergen", required = false) Concept codedAllergen,
	                          @RequestParam(value = "otherCodedAllergen", required = false) CodedOrFreeTextValue other,
	                          @RequestParam(value = "nonCodedAllergen", required = false) String[] nonCodedAllergen,
	                          @RequestParam(value = "allergyReactionConcepts", required = false) List<Concept> allergyReactionConcepts,
	                          @RequestParam(value = "severity", required = false) Concept severity,
	                          @RequestParam(value = "reactionNonCoded", required = false) String reactionNonCoded,
	                          @SpringBean("allergyProperties") AllergyProperties properties,
	                          @SpringBean("patientService") PatientService patientService, HttpServletRequest request) {
		
		Allergy allergy;
		if (allergyId == null) {
			allergen.setCodedAllergen(codedAllergen); //without this line, i cannot save coded allergens.
			if (other != null) {
				if (other.getCodedValue() != null) {
					allergen.setCodedAllergen(other.getCodedValue());
				} else if (other.getNonCodedValue() != null) {
					allergen.setNonCodedAllergen(other.getNonCodedValue());
				}
			} 
			if (!allergen.isCoded() && nonCodedAllergen.length > 0) {
				allergen.setNonCodedAllergen(nonCodedAllergen[0]);
			}
			allergy = new Allergy(patient, allergen, null, null, null);
		} else {
			allergy = patientService.getAllergies(patient).getAllergy(allergyId);
		}
		
		List<Concept> existingReactionConcepts = getAllergyReactionConcepts(allergy);
		for (Concept concept : existingReactionConcepts) {
			//This reaction has been removed
			if (!allergyReactionConcepts.contains(concept)) {
				allergy.removeReaction(getAllergyReactionByConcept(allergy, concept));
			}
		}
		
		//Add any newly added ones
		for (Concept concept : allergyReactionConcepts) {
			String nonCodedReaction = concept.equals(properties.getOtherNonCodedConcept()) ? reactionNonCoded : null;
			AllergyReaction reaction = allergy.getReaction(concept);
			if (reaction == null) {
				allergy.addReaction(new AllergyReaction(null, concept, nonCodedReaction));
			} else {
				reaction.setReactionNonCoded(nonCodedReaction);
			}
		}
		
		// need to explicitly handle severity because @BindParams doesn't handle the case where you unset it (and don't submit a parameter)
		allergy.setSeverity(severity);
		
		return allergy;
	}
	
	private void setModelAttributes(Allergy allergy, String returnUrl, PageModel model, AllergyProperties properties, UiUtils ui) {
		
		Concept unknownConcept = properties.getUnknownConcept();
		
		model.addAttribute("allergy", allergy);
        model.addAttribute("returnUrl", returnUrl);
		model.addAttribute("allergenTypes", Arrays.copyOfRange(AllergenType.values(), 0, 3));
		model.addAttribute("unknownConcept", unknownConcept);
		
		String unknownConceptUuid = unknownConcept.getUuid();
		
		//drug allergens
		Comparator comparator = new ByFormattedObjectComparator(ui);
		Concept concept = properties.getDrugAllergensConcept();
		model.addAttribute("drugAllergens", getSortedSetMembers(concept, comparator, unknownConceptUuid));
		
		//food allergens
		concept = properties.getFoodAllergensConcept();
		model.addAttribute("foodAllergens", getSortedSetMembers(concept, comparator, unknownConceptUuid));
		//environmental allergens
		concept = properties.getEnvironmentAllergensConcept();
		model.addAttribute("environmentalAllergens", getSortedSetMembers(concept, comparator, unknownConceptUuid));
		
		//allergy reactions
		concept = properties.getAllergyReactionsConcept();
		model.addAttribute("reactionConcepts", getSortedSetMembers(concept, comparator, unknownConceptUuid));
		
		//severities
		List<Concept> concepts = new ArrayList<Concept>();
		concept = properties.getMildSeverityConcept();
		if (concept != null) {
			concepts.add(concept);
		}
		concept = properties.getModerateSeverityConcept();
		if (concept != null) {
			concepts.add(concept);
		}
		concept = properties.getSevereSeverityConcept();
		if (concept != null) {
			concepts.add(concept);
		}
		model.addAttribute("severities", concepts);
		
		model.addAttribute("allergyReactionConcepts", getAllergyReactionConcepts(allergy));
		
		model.addAttribute("otherNonCodedConcept", properties.getOtherNonCodedConcept());
	}
	
	private AllergyReaction getAllergyReactionByConcept(Allergy allergy, Concept concept) {
		for (AllergyReaction ar : allergy.getReactions()) {
			if (ar.getReaction().equals(concept)) {
				return ar;
			}
		}
		return null;
	}
	
	/**
	 * This should be a utility method in allergyapi module
	 */
	private List<Concept> getAllergyReactionConcepts(Allergy allergy) {
		List<Concept> reactionConcepts = new ArrayList<Concept>(allergy.getReactions().size());
		for (AllergyReaction ar : allergy.getReactions()) {
			reactionConcepts.add(ar.getReaction());
		}
		return reactionConcepts;
	}
	
	private List<Concept> getSortedSetMembers(Concept concept, Comparator comparator, String unknownConceptUuid) {
		List<Concept> setMembers = new ArrayList<Concept>();
		Concept otherConcept = null;
		Concept unknownConcept = null;
		//Other non coded concept should be last in the list, remove it and add it as last
		//Unknown should come first
		if (concept != null) {
			for (Concept c : concept.getSetMembers()) {
				if (Allergen.getOtherNonCodedConceptUuid().equals(c.getUuid())) {
					otherConcept = c;
					continue;
				} else if (unknownConceptUuid.equals(c.getUuid())) {
					unknownConcept = c;
					continue;
				}
				setMembers.add(c);
			}
		}
		
		Collections.sort(setMembers, comparator);
		if (otherConcept != null) {
			setMembers.add(otherConcept);
		}
		if (unknownConcept != null) {
			setMembers.add(0, unknownConcept);
		}
		
		return setMembers;
	}
	
	private void addModelErrors(PageModel model, Errors errors, HttpSession session, MessageSourceService mss)
	    throws Exception {
		model.addAttribute("errors", errors);
		StringBuffer errorMessage = new StringBuffer();
		errorMessage.append("<ul>");
		for (ObjectError error : errors.getAllErrors()) {
			errorMessage.append("<li>");
			errorMessage.append(mss.getMessage(error.getCode(), error.getArguments(), error.getDefaultMessage(), null));
			errorMessage.append("</li>");
		}
		errorMessage.append("</ul>");
		session.setAttribute(UiCommonsConstants.SESSION_ATTRIBUTE_ERROR_MESSAGE, errorMessage.toString());
	}
}
