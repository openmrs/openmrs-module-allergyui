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
package org.openmrs.module.allergyui.extension.html;

import java.util.Comparator;

import org.openmrs.allergyapi.Allergy;

/**
 * Sorts allergies
 */
public class AllergyComparator implements Comparator<Allergy> {
	
	private Comparator comparator;
	
	public AllergyComparator(Comparator comparator) {
		this.comparator = comparator;
	}
	
	@Override
	public int compare(Allergy allergy1, Allergy allergy2) {
		Object obj1 = allergy1.getAllergen().getCodedAllergen();
		if (!allergy1.getAllergen().isCoded()) {
			obj1 = allergy1.getAllergen().getNonCodedAllergen();
		}
		
		Object obj2 = allergy2.getAllergen().getCodedAllergen();
		if (!allergy2.getAllergen().isCoded()) {
			obj2 = allergy2.getAllergen().getNonCodedAllergen();
		}
		
		//sort non coded allergen at the bottom
		if (obj1 instanceof String && obj2 instanceof String) {
			return obj1.toString().compareToIgnoreCase(obj2.toString());
		}
		
		return comparator.compare(obj1, obj2);
	}
}
