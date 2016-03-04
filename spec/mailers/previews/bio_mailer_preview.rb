# Preview all emails at http://localhost:3000/rails/mailers/bios
class BioMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/bios/submission
  def sample_bio
    Bio.pending.first || FactoryGirl.create(:bio)
  end

  def submission
    BioMailer.submission sample_bio
  end

  # Preview this email at http://localhost:3000/rails/mailers/bios/approval
  def approval
    BioMailer.approval Bio.approved.first || FactoryGirl.create(:approved_bio)
  end

  # Preview this email at http://localhost:3000/rails/mailers/bios/rejection
  def rejection
    BioMailer.rejection Bio.rejected.first || FactoryGirl.create(:rejected_bio)
  end

end
