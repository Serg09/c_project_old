#= require angular

app = angular.module('Crowdscribed', [])
app.controller('ContributionController', ['$scope', '$http', ($scope, $http) ->

  $scope.campaignId = null
  $scope.rewards = []
  $scope.$watch 'campaignId', ->
    loadRewards()

  $scope.selectedRewardId = null
  $scope.selectedReward = null
  $scope.$watch 'selectedRewardId', ->
    selectReward()

  $scope.handleRewardButtonClick = (e) ->
    $scope.selectedRewardId = $(e.currentTarget).data('reward-id')

  loadRewards = ->
    if $scope.campaignId
      url = "/campaigns/#{$scope.campaignId}/rewards.json"
      $http.get(url).then (response)->
        $scope.rewards = response.data
      , (error)->
        console.log "Unable to get the rewards: #{error}"
    else
      $scope.rewards = []

  selectReward = ->
    $scope.selectedReward = _.chain($scope.rewards).
      filter((r)->
        r['id'] == $scope.selectedRewardId
      ).
      first().
      value()

  return
])
