class ApplicationJob < ActiveJob::Base
  queue_as :default

  def job_scope(klass, id)
    instance = klass.unscoped.find(id)

    ActsAsTenant.with_tenant(instance.account) do
      Time.zone = instance.account.time_zone
      yield(instance)
    end
  end
end
