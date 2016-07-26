#= require angular

app = angular.module('Crowdscribed', [])
app.controller('ContributionController', ['$scope', '$http', ($scope, $http) ->

  $scope.campaignId = null
  $scope.rewards = []
  $scope.$watch 'campaignId', ->
    $scope.loadRewards()

  $scope.loadRewards = ->
    if $scope.campaignId
      url = "/campaigns/#{$scope.campaignId}/rewards.json"
      $http.get(url).then (response)->
        $scope.rewards = response.data
      , (error)->
        console.log "Unable to get the rewards: #{error}"
    else
      $scope.rewards = []

  return
])
