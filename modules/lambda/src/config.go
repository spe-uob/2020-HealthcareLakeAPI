/*
	Defines supported resource types
	 https://hl7.org/implement/standards/fhir/R4/


	Benchmarks show switch case is most efficient
		https://stackoverflow.com/a/52710077/13539522
*/

package main

// check if enabled resource
func AcceptedResource(lookup string) bool {
	switch lookup {
	case
		// Level 3 (Admin)
		"Patient",
		"Practitioner",
		"CareTeam",
		"Device",
		"Organization",
		"Location",
		"Healthcare Service",

		// Level 4: Clinical
		"AllergyIntolerance",
		"Condition",
		"Procedure",
		"FamilyMemberHistory",
		"CarePlan",
		"Goal",
		"ClinicalImpression",
		"AdverseEvent",
		"DetectedIssue",
		"RiskAssessment",

		// Level 4: Diagnostics
		"Observation",
		"DiagnosticReport",
		"ServiceRequest",
		"Media",
		"ImagingStudy",
		"MolecularSequence",
		"Specimen",
		"BodyStructure",

		// Level 4: Medications
		"MedicationRequest",
		"MedicationDispense",
		"MedicationAdministration",
		"MedicationStatement",
		"Medication",
		"MedicationKnowledge",
		"Immunization",
		"ImmunizationEvaluation",
		"ImmunizationRecommendation",

		// Level 4: Workflow
		"Task",
		"Appointment",
		"AppointmentResponse",
		"Schedule",
		"Slot",
		"NutritionOrder",
		"VisionPrescription",
		"ActivityDefinition",
		"PlanDefinition",
		"DeviceRequest",
		"DeviceUseStatement",
		"SupplyRequest",
		"SupplyDelivery":

		return true
	}
	return false
}
