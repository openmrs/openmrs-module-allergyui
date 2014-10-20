var app = angular.module("allergyApp", ['uicommons.widget.coded-or-free-text-answer']);
	
app.controller("allergyController", [ '$scope', function($scope) {

    $scope.allergen = null;
    $scope.allergenType = null;
    $scope.severity = null;
    $scope.nonCodedAllergen = null;
    $scope.otherCodedAllergen = null;

    $scope.canSave = function() {
        if ($scope.allergenType == 'DRUG') {
            if($scope.allergen && $scope.allergen != $scope.otherConceptId){
                return true;
            }

            return $scope.otherCodedAllergen;
        }
        else if ( $('#allergen-' + $scope.allergenType).is(':checked') ) {
			return $scope.nonCodedAllergen;
		}
    	return $scope.allergen;
    }

    $scope.$watch('allergenType', function(newValue, oldValue) {
        // clear allergen any time they change the type
        $scope.allergen = null;
        $scope.nonCodedAllergen = null;
        $scope.otherCodedAllergen = null;
        $('.coded_allergens').attr('checked', false);
    });

    $scope.$watch('allergen', function(newValue, oldValue) {
        // if you had already specified allergen, then change it, clear other fields
        if (oldValue) {
            $('input.allergy-reaction').attr('checked', false);
            $('input.allergy-severity').attr('checked', false);
            $('#allergy-comment').val('');

            $scope.nonCodedAllergen = null;
            $scope.otherCodedAllergen = null;
        }
    });

    $scope.otherFieldFocus = function() {
        $('#allergen-' + $scope.allergenType).attr('checked', true);
    };

    $scope.otherReactionFocus = function(reactionId) {
        $('#reaction-' + reactionId).attr('checked', true);
    };
    /*
     * This code lets us uncheck radio buttons.
     *
     * When an element is clicked, the model has not yet
     * been updated, so we check the value of the model 
     * to the value of the clicked element.  If they are 
     * identical, then the user is clicking the "current"
     * (selected) option and we can toggle it by setting 
     * the model to null.
     */
    $scope.toggle = function(event) {
        var keyboardEvent = event.type == 'keydown'
        var spaceOrEnterKey = keyboardEvent &&
                            (event.which == 13 ||
                             event.which == 32)
        var elem = event.target
        var modelKey = angular.element(elem).attr('ng-model')
        if (elem.value == $scope[modelKey]
           && (!keyboardEvent || spaceOrEnterKey)) {
            $scope[modelKey] = null
        } else {
            if (spaceOrEnterKey)
                $scope[modelKey] = elem.value
        }
        if (spaceOrEnterKey)
            event.preventDefault()
    }

}]);