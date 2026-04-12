class SendEmailJob < ApplicationJob
  queue_as :mailers

  retry_on StandardError, wait: :exponentially_longer, attempts: 3

  def perform(mailer_class, method_name, *args)
    mailer_class.constantize.send(method_name, *args).deliver_now
  end
end
