import { APIActions } from 'foremanReact/redux/API';
import { foremanUrl } from 'foremanReact/common/helpers';
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

export const bulkAssignPolicy = (params, handleSuccess, handleError) =>
  APIActions.put({
    url: foremanUrl('/api/v2/compliance/hosts/bulk/assign_compliance_policy'),
    key: BULK_ASSIGN_POLICY_KEY,
    params,
    handleSuccess,
    handleError,
  });

export const bulkUnassignPolicy = (params, handleSuccess, handleError) =>
  APIActions.put({
    url: foremanUrl('/api/v2/compliance/hosts/bulk/unassign_compliance_policy'),
    key: BULK_UNASSIGN_POLICY_KEY,
    params,
    handleSuccess,
    handleError,
  });
