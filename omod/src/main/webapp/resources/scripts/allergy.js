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

    $scope.checkOtherRadioButton = function() {
        document.getElementById('allergen-' + $scope.allergen).checked = true;
    }

    $scope.otherReactionFocus = function(reactionId) {
        $('#reaction-' + reactionId).attr('checked', true);
    };
}]);