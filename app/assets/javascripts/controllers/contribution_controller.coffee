#= require angular

app = angular.module('Crowdscribed', [])
app.controller('ContributionController', ['$scope', '$http', ($scope, $http) ->

  $scope.campaignId = null
  $scope.rewards = []
  $scope.$watch 'campaignId', ->
    loadRewards()

  $scope.selectedRewardId = null
  $scope.selectedReward = null
  $scope.customContributionAmount = null
  $scope.availableRewards = []

  $scope.$watch 'selectedRewardId', ->
    $scope.selectedReward.selected = false if $scope.selectedReward
    r = selectReward()
    if r
      r.selected = true
      $scope.customContributionAmount = null

  $scope.$watch 'customContributionAmount', ->
    refreshAvailableRewards()

  $scope.handleRewardButtonClick = (e) ->
    $scope.selectedRewardId = $(e.currentTarget).data('reward-id')

  $scope.clearSelection = () ->
    $scope.selectedRewardId = null

  loadRewards = ->
    if $scope.campaignId
      url = "/campaigns/#{$scope.campaignId}/rewards.json"
      $http.get(url).then (response)->
        $scope.rewards = response.data
        $scope.selectedRewardId = $scope.rewards[0].id if $scope.rewards.length > 0
      , (error)->
        console.log "Unable to get the rewards: #{error}"
    else
      $scope.rewards = []

  refreshAvailableRewards = ->
    if $scope.customContributionAmount
      $scope.availableRewards = _.filter $scope.rewards, (r) ->
        r.minimum_contribution <= $scope.customContributionAmount
    else
      $scope.availableRewards = []

  selectReward = ->
    $scope.selectedReward = _.chain($scope.rewards).
      filter((r)->
        r['id'] == $scope.selectedRewardId
      ).
      first().
      value()

  return
])
