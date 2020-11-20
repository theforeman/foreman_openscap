module ForemanOpenscap
  class CveFixtures
    def res_one(result_state = 'true')
      init_result({
       "references" => [
          { "ref_id" => "CVE-2019-16541", "ref_url" => "https://access.redhat.com/security/cve/CVE-2019-16541" },
          { "ref_id" => "CVE-2020-14040", "ref_url" => "https://access.redhat.com/security/cve/CVE-2020-14040" },
          { "ref_id" => "CVE-2020-14370", "ref_url" => "https://access.redhat.com/security/cve/CVE-2020-14370" },
          { "ref_id" => "CVE-2020-15586", "ref_url" => "https://access.redhat.com/security/cve/CVE-2020-15586" },
          { "ref_id" => "CVE-2020-16845", "ref_url" => "https://access.redhat.com/security/cve/CVE-2020-16845" },
          { "ref_id" => "CVE-2020-2252", "ref_url" => "https://access.redhat.com/security/cve/CVE-2020-2252" },
          { "ref_id" => "CVE-2020-2254", "ref_url" => "https://access.redhat.com/security/cve/CVE-2020-2254" },
          { "ref_id" => "CVE-2020-2255", "ref_url" => "https://access.redhat.com/security/cve/CVE-2020-2255" },
          { "ref_id" => "CVE-2020-8564", "ref_url" => "https://access.redhat.com/security/cve/CVE-2020-8564" }
        ]
      }, result_state)
    end

    def res_two(result_state = 'true')
      init_result({
        "references"=> [
          { "ref_id"=>"CVE-2020-2181", "ref_url"=>"https://access.redhat.com/security/cve/CVE-2020-2181"},
          { "ref_id"=>"CVE-2020-2182", "ref_url"=>"https://access.redhat.com/security/cve/CVE-2020-2182"},
          { "ref_id"=>"CVE-2020-2224", "ref_url"=>"https://access.redhat.com/security/cve/CVE-2020-2224"},
          { "ref_id"=>"CVE-2020-2225", "ref_url"=>"https://access.redhat.com/security/cve/CVE-2020-2225"},
          { "ref_id"=>"CVE-2020-2226", "ref_url"=>"https://access.redhat.com/security/cve/CVE-2020-2226"}
        ]
      }, result_state)
    end

    def res_three(result_state = 'true')
      init_result({
        "references" => [
          { "ref_id" => "CVE-2019-17638", "ref_url" => "https://access.redhat.com/security/cve/CVE-2019-17638" },
          { "ref_id" => "CVE-2020-2229", "ref_url" => "https://access.redhat.com/security/cve/CVE-2020-2229" },
          { "ref_id" => "CVE-2020-2230", "ref_url" => "https://access.redhat.com/security/cve/CVE-2020-2230" },
          { "ref_id" => "CVE-2020-2231", "ref_url" => "https://access.redhat.com/security/cve/CVE-2020-2231" }
        ]
      }, result_state)
    end

    def res_four(result_state = 'true')
      init_result({
        "references" => [
          { "ref_id" => "CVE-2019-17638", "ref_url" => "https://access.redhat.com/security/cve/CVE-2019-17638" },
          { "ref_id" => "CVE-2020-2220", "ref_url" => "https://access.redhat.com/security/cve/CVE-2020-2220" },
          { "ref_id" => "CVE-2020-2221", "ref_url" => "https://access.redhat.com/security/cve/CVE-2020-2221" },
          { "ref_id" => "CVE-2020-2222", "ref_url" => "https://access.redhat.com/security/cve/CVE-2020-2222" },
          { "ref_id" => "CVE-2020-2223", "ref_url" => "https://access.redhat.com/security/cve/CVE-2020-2223" },
          { "ref_id" => "CVE-2020-2229", "ref_url" => "https://access.redhat.com/security/cve/CVE-2020-2229" },
          { "ref_id" => "CVE-2020-2230", "ref_url" => "https://access.redhat.com/security/cve/CVE-2020-2230" },
          { "ref_id" => "CVE-2020-2231", "ref_url" => "https://access.redhat.com/security/cve/CVE-2020-2231" },
          { "ref_id" => "CVE-2020-8557", "ref_url" => "https://access.redhat.com/security/cve/CVE-2020-8557" }
        ]
      }, result_state)
    end

    def res_five(result_state = 'true')
      init_result({
        "references" => [
          { "ref_id" => "CVE-2020-2181", "ref_url" => "https://access.redhat.com/security/cve/CVE-2020-2181" },
          { "ref_id" => "CVE-2020-2182", "ref_url" => "https://access.redhat.com/security/cve/CVE-2020-2182" },
          { "ref_id" => "CVE-2020-2190", "ref_url" => "https://access.redhat.com/security/cve/CVE-2020-2190" },
          { "ref_id" => "CVE-2020-2224", "ref_url" => "https://access.redhat.com/security/cve/CVE-2020-2224" },
          { "ref_id" => "CVE-2020-2225", "ref_url" => "https://access.redhat.com/security/cve/CVE-2020-2225" },
          { "ref_id" => "CVE-2020-2226", "ref_url" => "https://access.redhat.com/security/cve/CVE-2020-2226" }
        ]
      }, result_state)
    end

    def one
      [res_one, res_two, res_three, res_four, res_five]
    end

    def two
      [res_one('false'), res_two, res_three('false')]
    end

    def ids_from(fixture)
      fixture['references'].pluck('ref_id')
    end

    private

    def init_result(data, result_state)
      data['result'] = result_state
      data
    end
  end
end
