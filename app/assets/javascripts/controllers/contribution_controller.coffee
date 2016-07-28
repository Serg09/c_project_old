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

  loadRewards = ->
    if $scope.campaignId
      url = "/campaigns/#{$scope.campaignId}/rewards.json"
      $http.get(url).then (response)->
        $scope.rewards = _.map(response.data, prepareReward)
      , (error)->
        console.log "Unable to get the rewards: #{error}"
    else
      $scope.rewards = []

  prepareReward = (reward)->
    if reward.house_reward_id && ! reward.long_description
      getHouseReward reward.house_reward_id, (houseReward)->
        reward.long_description = houseReward.long_description
    reward

  getHouseReward = (id, callback)->
    url = "/house_rewards/#{id}.json"
    $http.get(url).then (response)->
      callback response.data

  selectReward = ->
    $scope.selectedReward = _.chain($scope.rewards).
      filter((r)->
        r['id'] == $scope.selectedRewardId
      ).
      first().
      value()

  return
])
