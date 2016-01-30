When /^an administrator has approved the bio for (#{AUTHOR})$/ do |author|
  expect(author.pending_bio).not_to be_nil
  author.pending_bio.status = Bio.APPROVED
  author.pending_bio.save!
end
