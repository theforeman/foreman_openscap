import { APIActions } from 'foremanReact/redux/API';

import {
  fetchPolicies,
  bulkAssignPolicy,
  bulkUnassignPolicy,
} from '../actions';
import {
  POLICIES_KEY,
  BULK_ASSIGN_POLICY_KEY,
  BULK_UNASSIGN_POLICY_KEY,
} from '../constants';

jest.mock('foremanReact/redux/API', () => ({
  APIActions: {
    get: jest.fn(params => ({
      type: 'API_GET',
      params,
    })),
    put: jest.fn(params => ({
      type: 'API_PUT',
      params,
    })),
  },
}));

jest.mock('foremanReact/common/helpers', () => ({
  foremanUrl: jest.fn(path => path),
}));

jest.mock('foremanReact/common/I18n', () => ({
  translate: jest.fn(text => text),
}));

describe('Compliance Policy Actions', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    APIActions.put.mockReturnValue({ type: 'API_PUT' });
  });

  describe('fetchPolicies', () => {
    it('dispatches GET request to compliance policies API', () => {
      const action = fetchPolicies();

      expect(APIActions.get).toHaveBeenCalledWith({
        url: '/api/v2/compliance/policies',
        key: POLICIES_KEY,
      });
      expect(action.type).toBe('API_GET');
    });
  });

  describe('bulkAssignPolicy', () => {
    const requestBody = {
      included: {
        search: 'id ^ (1,2,3)',
      },
      policy_id: '5',
      organization_id: 1,
      location_id: 2,
    };
    const handleSuccess = jest.fn();
    const handleError = jest.fn();

    it('dispatches PUT request to assign policy endpoint', () => {
      bulkAssignPolicy(requestBody, handleSuccess, handleError);

      expect(APIActions.put).toHaveBeenCalledTimes(1);
      const callArgs = APIActions.put.mock.calls[0][0];

      expect(callArgs.key).toBe(BULK_ASSIGN_POLICY_KEY);
      expect(callArgs.url).toContain(
        '/api/v2/compliance/hosts/bulk/assign_compliance_policy'
      );
      expect(callArgs.params).toEqual(requestBody);
      expect(callArgs.handleSuccess).toBe(handleSuccess);
      expect(callArgs.handleError).toBe(handleError);
    });

    it('passes error handler callback', () => {
      bulkAssignPolicy(requestBody, handleSuccess, handleError);
      const callArgs = APIActions.put.mock.calls[0][0];
      expect(callArgs.handleError).toBe(handleError);
    });
  });

  describe('bulkUnassignPolicy', () => {
    const requestBody = {
      included: {
        search: 'name ~ test',
      },
      policy_id: '3',
      organization_id: 1,
      location_id: 2,
    };
    const handleSuccess = jest.fn();
    const handleError = jest.fn();

    it('dispatches PUT request to unassign policy endpoint', () => {
      bulkUnassignPolicy(requestBody, handleSuccess, handleError);

      expect(APIActions.put).toHaveBeenCalledTimes(1);
      const callArgs = APIActions.put.mock.calls[0][0];

      expect(callArgs.key).toBe(BULK_UNASSIGN_POLICY_KEY);
      expect(callArgs.url).toContain(
        '/api/v2/compliance/hosts/bulk/unassign_compliance_policy'
      );
      expect(callArgs.params).toEqual(requestBody);
      expect(callArgs.handleSuccess).toBe(handleSuccess);
      expect(callArgs.handleError).toBe(handleError);
    });

    it('passes error handler callback', () => {
      bulkUnassignPolicy(requestBody, handleSuccess, handleError);
      const callArgs = APIActions.put.mock.calls[0][0];
      expect(callArgs.handleError).toBe(handleError);
    });
  });
});
