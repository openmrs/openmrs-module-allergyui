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
package org.openmrs.module.allergyui.fragment.controller;

import java.util.Collections;
import java.util.Comparator;

import org.openmrs.Patient;
import org.openmrs.module.allergyapi.Allergies;
import org.openmrs.module.allergyapi.api.PatientService;
import org.openmrs.module.allergyui.extension.html.AllergyComparator;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.annotation.FragmentParam;
import org.openmrs.ui.framework.annotation.SpringBean;
import org.openmrs.ui.framework.fragment.FragmentModel;
import org.openmrs.ui.util.ByFormattedObjectComparator;


public class AllergiesFragmentController {
	
	public void controller(FragmentModel model, @FragmentParam("patientId") Patient patient, UiUtils ui,
	                       @SpringBean("allergyService") PatientService patientService) {
		
		Allergies allergies = patientService.getAllergies(patient);
		Comparator comparator = new AllergyComparator(new ByFormattedObjectComparator(ui));
		Collections.sort(allergies, comparator);
		
		model.addAttribute("allergies", allergies);
	}
}
