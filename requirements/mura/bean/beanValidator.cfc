	component output="false" accessors="true" extends="mura.cfobject" {

	public struct function getValidationsByContext(required any object, string context="") {
		
		var contextValidations = {};
		var validationStruct = arguments.object.getValidations();
			
		// Loop over each proeprty in the validation struct looking for rule structures
		for(var property in validationStruct.properties) {
				
		// For each array full of rules for the property, loop over them and check for the context
			for(var r=1; r<=arrayLen(validationStruct.properties[property]); r++) {
					
			var rule = validationStruct.properties[property][r];
					
			// Verify that either context doesn't exist, or that the context passed in is in the list of contexts for this rule
			if(!structKeyExists(rule, "contexts") || listFindNoCase(rule.contexts, arguments.context)) {
						
					if(!structKeyExists(contextValidations, property)) {
						contextValidations[ property ] = [];
					}
						
					for(var constraint in rule) {
						if(constraint != "contexts" && constraint != "conditions") {
							var constraintDetails = {
								constraintType=constraint,
								constraintValue=rule[ constraint ]
							};
							if(structKeyExists(rule, "conditions")) {
								constraintDetails.conditions = rule.conditions;
							}
							if(structKeyExists(rule, "message")) {
								constraintDetails.message = rule.message;
							}
							if(structKeyExists(rule, "rbkey")) {
								constraintDetails.rbkey = rule.rbkey;
							}
							arrayAppend(contextValidations[ property ], constraintDetails);
						}
					}
				}
			}
		}

		return contextValidations;
	}

	
	
	public boolean function getConditionsMeetFlag( required any object, required string conditions) {
		
		var validationStruct = arguments.object.getValidations();

		var conditionsArray = listToArray(arguments.conditions);
		
		// Loop over each condition to check if it is true
		for(var x=1; x<=arrayLen(conditionsArray); x++) {
			
			var conditionName = conditionsArray[x];
			
			// Make sure that the condition is defined in the meta data
			if(structKeyExists(validationStruct, "conditions") && structKeyExists(validationStruct.conditions, conditionName)) {
				
				var allConditionConstraintsMeet = true;
				
				// Loop over each propertyIdentifier for this condition
				for(var conditionPropertyIdentifier in validationStruct.conditions[ conditionName ]) {
					
					// Loop over each constraint for the property identifier to validate the constraint
					for(var constraint in validationStruct.conditions[ conditionName ][ conditionPropertyIdentifier ]) {
						if(structKeyExists(variables, "validate_#constraint#") && !invokeMethod("validate_#constraint#", {object=arguments.object, propertyIdentifier=conditionPropertyIdentifier, constraintValue=validationStruct.conditions[ conditionName ][ conditionPropertyIdentifier ][ constraint ]})) {
							allConditionConstraintsMeet = false;	
						}
					}
				}
				
				// If all constraints of this condition are meet, then we no that one condition is meet for this rule.
				if( allConditionConstraintsMeet ) {
					return true;
				}
			}
		}
		
		return false;
	}
	
	public any function getPopulatedPropertyValidationContext(required any object, required string propertyName, string context="") {
		
		var validationStruct = arguments.object.getValidations();
		
		if(structKeyExists(validationStruct, "populatedPropertyValidation") && structKeyExists(validationStruct.populatedPropertyValidation, arguments.propertyName)) {
			for(var v=1; v <= arrayLen(validationStruct.populatedPropertyValidation[arguments.propertyName]); v++) {
				var conditionsMeet = true;
				if(structKeyExists(validationStruct.populatedPropertyValidation[arguments.propertyName][v], "conditions")) {
					conditionsMeet = getConditionsMeetFlag(object=arguments.object, conditions=validationStruct.populatedPropertyValidation[arguments.propertyName][v].conditions);
				}
				if(conditionsMeet) {
					return validationStruct.populatedPropertyValidation[arguments.propertyName][v].validate;
				}
			}

		}
		
		return arguments.context;
	}
	
	public any function validate(required any object, string context="") {
		
		var errorsStruct={};
		
		// If the context was 'false' then we don't do any validation
		if(!isBoolean(arguments.context) || arguments.context) {
			// Get the valdiations for this context
			var contextValidations = getValidationsByContext(object=arguments.object, context=arguments.context);
			
			// Loop over each property in the validations for this context
			for(var propertyIdentifier in contextValidations) {
				
				// First make sure that the proerty exists
				//if(arguments.object.hasProperty( propertyIdentifier )) {
					
					// Loop over each of the constraints for this given property
					for(var c=1; c<=arrayLen(contextValidations[ propertyIdentifier ]); c++) {
						
						// Check that one of the conditions were meet if there were conditions for this constraint
						var conditionMeet = true;
						if(structKeyExists(contextValidations[ propertyIdentifier ][c], "conditions")) {
							conditionMeet = getConditionsMeetFlag( object=arguments.object, conditions=contextValidations[ propertyIdentifier ][ c ].conditions );
						}
						
						// Now if a condition was meet we can actually test the individual validation rule
						if(conditionMeet) {
							validateConstraint(object=arguments.object, propertyIdentifier=propertyIdentifier, constraintDetails=contextValidations[ propertyIdentifier ][c], errorsStruct=errorStruct, context=arguments.context);	
						}
					}	
				//}
			}
		}
		
		return errorsStruct;
	}
	
	
	public any function validateConstraint(required any object, required string propertyIdentifier, required struct constraintDetails, required any errorsStruct, required string context) {
		if(!structKeyExists(variables, "validate_#arguments.constraintDetails.constraintType#")) {
			throw("You have an error in the #arguments.object.getClassName()#.json validation file.  You have a constraint defined for '#arguments.propertyIdentifier#' that is called '#arguments.constraintDetails.constraintType#' which is not a valid constraint type");
		}
		
		var isValid = invokeMethod("validate_#arguments.constraintDetails.constraintType#", {object=arguments.object, propertyIdentifier=arguments.propertyIdentifier, constraintValue=arguments.constraintDetails.constraintValue});	
					
		if(!isValid) {
			if(structKeyExist(arguments.constraintDetails,'rbkey')){
				arguments.errorsStruct[arguments.propertyIdentifier]=getBean('settingsManager').getSite(arguments.object.getSiteID()).getRBFactory().getKey(arguments.constraintDetails.rbkey);
			} else {
				arguments.errorsStruct[arguments.propertyIdentifier]=arguments.constraintDetails.message;
			}
		}
	}
	
	
	// ================================== VALIDATION CONSTRAINT LOGIC ===========================================
	
	public boolean function validate_required(required any object, required string propertyIdentifier, boolean constraintValue=true) {
		var propertyValue = arguments.object.invokeMethod("get#arguments.propertyIdentifier#");
		if(!isNull(propertyValue) && (isObject(propertyValue) || (isArray(propertyValue) && arrayLen(propertyValue)) || (isStruct(propertyValue) && structCount(propertyValue)) || (isSimpleValue(propertyValue) && len(propertyValue)))) {
			return true;
		}
		return false;
	}
	
	public boolean function validate_dataType(required any object, required string propertyIdentifier, required any constraintValue) {
		var propertyValue = arguments.object.invokeMethod("get#arguments.propertyIdentifier#");
		if(listFindNoCase("any,array,binary,boolean,component,creditCard,date,time,email,eurodate,float,numeric,guid,integer,query,range,regex,regular_expression,ssn,social_security_number,string,telephone,url,uuid,usdate,zipcode",arguments.constraintValue)) {
			if(isNull(propertyValue) || isValid(arguments.constraintValue, propertyValue)) {
				return true;
			}
		} else {
			throw("The validation file: #arguments.object.getClassName()#.json has an incorrect dataType constraint value of '#arguments.constraintValue#' for one of it's properties.  Valid values are: any,array,binary,boolean,component,creditCard,date,time,email,eurodate,float,numeric,guid,integer,query,range,regex,regular_expression,ssn,social_security_number,string,telephone,url,uuid,usdate,zipcode");
		}
		
		return false;
	}
	
	public boolean function validate_minValue(required any object, required string propertyIdentifier, required numeric constraintValue) {
		var propertyValue = arguments.object.invokeMethod("get#arguments.propertyIdentifier#");
		if(isNull(propertyValue) || (isNumeric(propertyValue) && propertyValue >= arguments.constraintValue) ) {
			return true;
		}
		return false;
	}
	
	public boolean function validate_maxValue(required any object, required string propertyIdentifier, required numeric constraintValue) {
		var propertyValue = arguments.object.invokeMethod("get#arguments.propertyIdentifier#");
		if(isNull(propertyValue) || (isNumeric(propertyValue) && propertyValue <= arguments.constraintValue) ) {
			return true;
		}
		return false;
	}
	
	public boolean function validate_minLength(required any object, required string propertyIdentifier, required numeric constraintValue) {
		var propertyValue = arguments.object.invokeMethod("get#arguments.propertyIdentifier#");
		if(isNull(propertyValue) || (isSimpleValue(propertyValue) && len(propertyValue) >= arguments.constraintValue) ) {
			return true;
		}
		return false;
	}
	
	public boolean function validate_maxLength(required any object, required string propertyIdentifier, required numeric constraintValue) {
		var propertyValue = arguments.object.invokeMethod("get#arguments.propertyIdentifier#");
		if(isNull(propertyValue) || (isSimpleValue(propertyValue) && len(propertyValue) <= arguments.constraintValue) ) {
			return true;
		}
		return false;
	}
	
	public boolean function validate_minCollection(required any object, required string propertyIdentifier, required numeric constraintValue) {
		var propertyValue = arguments.object.invokeMethod("get#arguments.propertyIdentifier#");
		if(isNull(propertyValue) || (isArray(propertyValue) && arrayLen(propertyValue) >= arguments.constraintValue) || (isStruct(propertyValue) && structCount(propertyValue) >= arguments.constraintValue)) {
			return true;
		}
		return false;
	}
	
	public boolean function validate_maxCollection(required any object, required string propertyIdentifier, required numeric constraintValue) {
		var propertyValue = arguments.object.invokeMethod("get#arguments.propertyIdentifier#");
		if(isNull(propertyValue) || (isArray(propertyValue) && arrayLen(propertyValue) <= arguments.constraintValue) || (isStruct(propertyValue) && structCount(propertyValue) <= arguments.constraintValue)) {
			return true;
		}
		return false;
	}
	
	public boolean function validate_minList(required any object, required string propertyIdentifier, required numeric constraintValue) {
		var propertyValue = arguments.object.invokeMethod("get#arguments.propertyIdentifier#");
		if((!isNull(propertyValue) && isSimpleValue(propertyValue) && listLen(propertyValue) >= arguments.constraintValue) || (isNull(propertyValue) && arguments.constraintValue == 0)) {
			return true;
		}
		return false;
	}
	
	public boolean function validate_maxList(required any object, required string propertyIdentifier, required numeric constraintValue) {
		var propertyValue = arguments.object.invokeMethod("get#arguments.propertyIdentifier#");
		if((!isNull(propertyValue) && isSimpleValue(propertyValue) && listLen(propertyValue) <= arguments.constraintValue) || (isNull(propertyValue) && arguments.constraintValue == 0)) {
			return true;
		}
		return false;
	}
	
	public boolean function validate_method(required any object, required string propertyIdentifier, required string constraintValue) {
		return arguments.object.invokeMethod(arguments.constraintValue);
	}
	
	public boolean function validate_lte(required any object, required string propertyIdentifier, required string constraintValue) {
		var propertyValue = arguments.object.invokeMethod("get#arguments.propertyIdentifier#");
		if(!isNull(propertyValue) && !isNull(propertyValue) && propertyValue <= arguments.constraintValue) {
			return true;
		}
		return false;
	}
	
	public boolean function validate_lt(required any object, required string propertyIdentifier, required string constraintValue) {
		var propertyValue = arguments.object.invokeMethod("get#arguments.propertyIdentifier#");
		if(!isNull(propertyValue) && !isNull(propertyValue) && propertyValue < arguments.constraintValue) {
			return true;
		}
		return false;
	}
	
	public boolean function validate_gte(required any object, required string propertyIdentifier, required string constraintValue) {
		var propertyValue = arguments.object.invokeMethod("get#arguments.propertyIdentifier#");
		if(!isNull(propertyValue) && !isNull(propertyValue) && propertyValue >= arguments.constraintValue) {
			return true;
		}
		return false;
	}
	
	public boolean function validate_gt(required any object, required string propertyIdentifier, required string constraintValue) {
		var propertyValue = arguments.object.invokeMethod("get#arguments.propertyIdentifier#");
		if(!isNull(propertyValue) && !isNull(propertyValue) && propertyValue > arguments.constraintValue) {
			return true;
		}
		return false;
	}
	
	public boolean function validate_eq(required any object, required string propertyIdentifier, required string constraintValue) {
		var objectOnly = arguments.object.getLastObjectByPropertyIdentifier( arguments.propertyIdentifier );
		var propertyValue = arguments.object.invokeMethod("get#arguments.propertyIdentifier#");
		if(!isNull(propertyValue) && !isNull(propertyValue) && propertyValue == arguments.constraintValue) {
			return true;
		}
		return false;
	}
	
	public boolean function validate_neq(required any object, required string propertyIdentifier, required string constraintValue) {
		var propertyValue = arguments.object.invokeMethod("get#arguments.propertyIdentifier#");
		if(!isNull(propertyValue) && !isNull(propertyValue) && propertyValue != arguments.constraintValue) {
			return true;
		}
		return false;
	}
	
	public boolean function validate_lteProperty(required any object, required string propertyIdentifier, required string constraintValue) {
		var propertyValue = arguments.object.invokeMethod("get#arguments.propertyIdentifier#");
		var compairPropertyValue =  arguments.object.getLastObjectByPropertyIdentifier( arguments.constraintValue ).invokeMethod("get#listLast(arguments.constraintValue,'._')#");
		if(!isNull(propertyValue) && !isNull(compairPropertyValue) && propertyValue <= compairPropertyValue) {
			return true;
		}
		return false;
	}
	
	public boolean function validate_ltProperty(required any object, required string propertyIdentifier, required string constraintValue) {
		var propertyValue = arguments.object.invokeMethod("get#arguments.propertyIdentifier#");
		var compairPropertyValue =  arguments.object.getLastObjectByPropertyIdentifier( arguments.constraintValue ).invokeMethod("get#listLast(arguments.constraintValue,'._')#");
		if(!isNull(propertyValue) && !isNull(compairPropertyValue) && propertyValue < compairPropertyValue) {
			return true;
		}
		return false;
	}
	
	public boolean function validate_gteProperty(required any object, required string propertyIdentifier, required string constraintValue) {
		var propertyValue = arguments.object.invokeMethod("get#arguments.propertyIdentifier#");
		var compairPropertyValue =  arguments.object.getLastObjectByPropertyIdentifier( arguments.constraintValue ).invokeMethod("get#listLast(arguments.constraintValue,'._')#");
		if(!isNull(propertyValue) && !isNull(compairPropertyValue) && propertyValue >= compairPropertyValue) {
			return true;
		}
		return false;
	}
	
	public boolean function validate_gtProperty(required any object, required string propertyIdentifier, required string constraintValue) {
		var propertyValue = arguments.object.invokeMethod("get#arguments.propertyIdentifier#");
		var compairPropertyValue =  arguments.object.getLastObjectByPropertyIdentifier( arguments.constraintValue ).invokeMethod("get#listLast(arguments.constraintValue,'._')#");
		if(!isNull(propertyValue) && !isNull(compairPropertyValue) && propertyValue > compairPropertyValue) {
			return true;
		}
		return false;
	}
	
	public boolean function validate_eqProperty(required any object, required string propertyIdentifier, required string constraintValue) {
		var propertyValue = arguments.object.invokeMethod("get#arguments.propertyIdentifier#");
		var compairPropertyValue = arguments.object.getLastObjectByPropertyIdentifier( arguments.constraintValue ).invokeMethod("get#listLast(arguments.constraintValue,'._')#");
		if((isNull(propertyValue) && isNull(compairPropertyValue)) || (!isNull(propertyValue) && !isNull(compairPropertyValue) && propertyValue == compairPropertyValue)) {
			return true;
		}
		return false;
	}
	
	public boolean function validate_neqProperty(required any object, required string propertyIdentifier, required string constraintValue) {
		var propertyValue = arguments.object.invokeMethod("get#arguments.propertyIdentifier#");
		var compairPropertyValue = arguments.object.getLastObjectByPropertyIdentifier( arguments.constraintValue ).invokeMethod("get#listLast(arguments.constraintValue,'._')#");
		if(!isNull(propertyValue) && !isNull(compairPropertyValue) && propertyValue != compairPropertyValue) {
			return true;
		}
		return false;
	}
	
	public boolean function validate_inList(required any object, required string propertyIdentifier, required string constraintValue) {
		var propertyValue = arguments.object.invokeMethod("get#arguments.propertyIdentifier#");
		if(!isNull(propertyValue) && listFindNoCase(arguments.constraintValue, propertyValue)) {
			return true;
		}
		return false;
	}
	
	public boolean function validate_regex(required any object, required string propertyIdentifier, required string constraintValue) {
		var propertyValue = arguments.object.invokeMethod("get#arguments.propertyIdentifier#");
		if(isNull(propertyValue) || isValid("regex", propertyValue, arguments.constraintValue)) {
			return true;
		}
		return false;
	}

}