import { translate as __ } from 'foremanReact/common/I18n';

export const FAIL_RULE_SEARCH = 'fails_xccdf_rule';

export const HOSTS_API_PATH = '/api/hosts';
export const HOSTS_API_REQUEST_KEY = 'HOSTS';
export const REPORT_LOG_REQUEST_KEY = 'ARF_REPORT_LOG';

export const JOB_INVOCATION_PATH = '/job_invocations';
export const JOB_INVOCATION_API_PATH = '/api/job_invocations';
export const JOB_INVOCATION_API_REQUEST_KEY = 'OPENSCAP_REX_JOB_INVOCATIONS';

export const SNIPPET_SH = 'urn:xccdf:fix:script:sh';
export const SNIPPET_ANSIBLE = 'urn:xccdf:fix:script:ansible';

export const TOOLTIP_COPIED_EXIT_DELAY_MS = 1500;
export const TOOLTIP_DEFAULT_EXIT_DELAY_MS = 600;

export const WIZARD_TITLES = {
  snippetSelect: __('Select snippet'),
  reviewHosts: __('Review hosts'),
  reviewRemediation: __('Review remediation'),
  finish: __('Done'),
};

export const BULK_CHANGE_OPENSCAP_PROXY_KEY = 'BULK_CHANGE_OPENSCAP_PROXY';
export const OPENSCAP_PROXIES_KEY = 'OPENSCAP_PROXIES_KEY';

export const CHANGE_OPENSCAP_MODAL_ID = 'BULK_CHANGE_OPENSCAP_PROXY_MODAL';
