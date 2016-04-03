# Collects campaign donations by executing PayPal
# transactions that have already been authorized
class DonationCollector
  @queue = :donation_collection
end
