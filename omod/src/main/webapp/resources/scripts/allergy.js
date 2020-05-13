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
        $('.coded_allergens').prop('checked', false);
        $('[ng-model=otherCodedAllergen]').hide();
        $('[ng-model=nonCodedAllergen]').hide();
    });

    $scope.$watch('allergen', function(newValue, oldValue) {
        // if you had already specified allergen, then change it, clear other fields
        if (oldValue) {
            $('input.allergy-reaction').prop('checked', false);
            $('input.allergy-severity').prop('checked', false);
            $('#allergy-comment').val('');
            $('[ng-model=otherCodedAllergen]').hide();
            $('[name=reactionNonCoded]').hide();

            $scope.nonCodedAllergen = null;
            $scope.otherCodedAllergen = null;
        }
    });

    $scope.controlOtherAllergenInputVisibility = function() {
        if ($('#allergen-' + $scope.allergenType).prop('checked')) {
            $('[ng-model=otherCodedAllergen]').show();
            $('[ng-model=nonCodedAllergen]').show();
        } else {
            $('[ng-model=otherCodedAllergen]').hide();
            $('[ng-model=nonCodedAllergen]').hide();
        }
    }

    $scope.controlOtherReactionInputVisibility = function(reactionId) {
        if ($('#reaction-' + reactionId).prop('checked')) {
            $('[name=reactionNonCoded]').show();
        } else {
            $('[name=reactionNonCoded]').hide();
        }
    }

    $scope.initOtherReactionInputVisibility = function(isOtherReactionEnabled) {
       if (isOtherReactionEnabled) {
           $('[name=reactionNonCoded]').show();
       } else {
           $('[name=reactionNonCoded]').hide();
       }
    }

    $scope.otherFieldFocus = function() {
        $('#allergen-' + $scope.allergenType).prop('checked', true);
        $scope.controlOtherAllergenInputVisibility();
    };


    $scope.otherReactionFocus = function(reactionId) {
        $('#reaction-' + reactionId).prop('checked', true);
        $scope.controlOtherReactionInputVisibility(reactionId);
    };

    $scope.selectOtherAllergenRadioInput = function() {
        $('#allergen-' + $scope.allergenType).prop('checked', true);
        $scope.controlOtherAllergenInputVisibility();
    }
}]);