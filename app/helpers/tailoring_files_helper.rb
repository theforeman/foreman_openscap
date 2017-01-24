module TailoringFilesHelper
  def run_tailoring_proxy_check
    ForemanOpenscap::OpenscapProxyVersionCheck.new.run
  end
end
