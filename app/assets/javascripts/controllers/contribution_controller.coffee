#= require angular

app = angular.module('Crowdscribed', [])
app.controller('ContributionController', ['$scope', ($scope) ->
  $scope.test = "Dynamic content will go here"

  return
])
