class SeedDefaultEnvelopesForAccountJob < ApplicationJob
  def perform(account_id)
    ActsAsTenant.with_tenant(Account.find(account_id)) do
      default_envelopes.each do |group, envelopes|
        envelope_group = EnvelopeGroup.find_or_create_by!(name: group)

        envelopes.each do |envelope_name|
          envelope_group.envelopes.find_or_create_by!(name: envelope_name)
        end
      end
    end
  end

  private

  def default_envelopes
    YAML.load_file(Rails.root.join("lib", "default_envelopes.yml"))
  end
end
