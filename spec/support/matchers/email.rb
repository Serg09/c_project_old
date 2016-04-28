RSpec::Matchers.define :receive_an_email_with_subject do |subject|
  match do |email|
    message = ActionMailer::Base.deliveries.
      select{|m| m.to.include?(email)}.
      select{|m| subject === m.subject}.
      first
    !!message
  end

  failure_message do |email|
    "expected an email to #{email} with subject \"#{subject}\", but none was received"
  end

  failure_message_when_negated do |email|
    "expected no email to #{email} with subject \"#{subject}\", but one was received"
  end

  description do
    "receive an email with the subject \"#{subject}\""
  end
end
