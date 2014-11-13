module ScaptimonyPoliciesHelper
  def profiles_selection
    return [] if @scap_content.blank?
    @scap_content.scap_content_profiles
  end
end
