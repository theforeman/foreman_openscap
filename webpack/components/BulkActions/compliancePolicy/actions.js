import { APIActions } from 'foremanReact/redux/API';
import { foremanUrl } from 'foremanReact/common/helpers';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  POLICIES_KEY,
  BULK_ASSIGN_POLICY_KEY,
  BULK_UNASSIGN_POLICY_KEY,
} from './constants';

export const fetchPolicies = () =>
  APIActions.get({
    url: foremanUrl('/api/v2/compliance/policies'),
    key: POLICIES_KEY,
  });

export const bulkAssignPolicy = (requestBody, onSuccess, onError) => {
  // eslint-disable-next-line camelcase
  const { policy_id, ...params } = requestBody;
  const queryParams = new URLSearchParams(params);
  const url = foremanUrl(
    `/compliance/policies/update_multiple_hosts?${queryParams.toString()}`
  );

  return APIActions.post({
    url,
    key: BULK_ASSIGN_POLICY_KEY,
    params: { policy: { id: policy_id } },
    successToast: () =>
      __('Successfully assigned compliance policy to selected hosts'),
    handleSuccess: onSuccess,
    handleError: onError,
  });
};

export const bulkUnassignPolicy = (requestBody, onSuccess, onError) => {
  // eslint-disable-next-line camelcase
  const { policy_id, ...params } = requestBody;
  const queryParams = new URLSearchParams(params);
  const url = foremanUrl(
    `/compliance/policies/remove_policy_from_multiple_hosts?${queryParams.toString()}`
  );

  return APIActions.post({
    url,
    key: BULK_UNASSIGN_POLICY_KEY,
    params: { policy: { id: policy_id } },
    successToast: () =>
      __('Successfully unassigned compliance policy from selected hosts'),
    handleSuccess: onSuccess,
    handleError: onError,
  });
};
