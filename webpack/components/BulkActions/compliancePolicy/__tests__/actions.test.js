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
    post: jest.fn(params => ({
      type: 'API_POST',
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
      search: 'id ^ (1,2,3)',
      policy_id: '5',
      organization_id: 1,
      location_id: 2,
    };
    const onSuccess = jest.fn();
    const onError = jest.fn();

    it('dispatches POST request to assign policy endpoint', () => {
      bulkAssignPolicy(requestBody, onSuccess, onError);

      expect(APIActions.post).toHaveBeenCalledTimes(1);
      const callArgs = APIActions.post.mock.calls[0][0];

      expect(callArgs.key).toBe(BULK_ASSIGN_POLICY_KEY);
      expect(callArgs.url).toContain(
        '/compliance/policies/update_multiple_hosts'
      );
      expect(callArgs.params).toEqual({ policy: { id: '5' } });
      expect(callArgs.handleSuccess).toBe(onSuccess);
      expect(callArgs.handleError).toBe(onError);
    });

    it('includes search parameter in URL', () => {
      bulkAssignPolicy(requestBody, onSuccess, onError);

      const callArgs = APIActions.post.mock.calls[0][0];
      const url = new URL(callArgs.url, 'http://example.com');

      expect(url.searchParams.get('search')).toBe('id ^ (1,2,3)');
    });

    it('includes organization_id in URL when provided', () => {
      bulkAssignPolicy(requestBody, onSuccess, onError);

      const callArgs = APIActions.post.mock.calls[0][0];
      const url = new URL(callArgs.url, 'http://example.com');

      expect(url.searchParams.get('organization_id')).toBe('1');
    });

    it('includes location_id in URL when provided', () => {
      bulkAssignPolicy(requestBody, onSuccess, onError);

      const callArgs = APIActions.post.mock.calls[0][0];
      const url = new URL(callArgs.url, 'http://example.com');

      expect(url.searchParams.get('location_id')).toBe('2');
    });

    it('does not include organization_id when not provided', () => {
      const bodyWithoutOrg = {
        search: 'id ^ (1,2,3)',
        policy_id: '5',
      };

      bulkAssignPolicy(bodyWithoutOrg, onSuccess, onError);

      const callArgs = APIActions.post.mock.calls[0][0];
      const url = new URL(callArgs.url, 'http://example.com');

      expect(url.searchParams.get('organization_id')).toBeNull();
    });

    it('has success toast message', () => {
      bulkAssignPolicy(requestBody, onSuccess, onError);

      const callArgs = APIActions.post.mock.calls[0][0];
      const toastMessage = callArgs.successToast();

      expect(toastMessage).toContain('assigned');
      expect(toastMessage).toContain('compliance policy');
    });

    it('has error toast handler', () => {
      bulkAssignPolicy(requestBody, onSuccess, onError);

      const callArgs = APIActions.post.mock.calls[0][0];
      const errorMessage = 'Assignment failed';
      const toastMessage = callArgs.errorToast({ message: errorMessage });

      expect(toastMessage).toBe(errorMessage);
    });
  });

  describe('bulkUnassignPolicy', () => {
    const requestBody = {
      search: 'name ~ test',
      policy_id: '3',
      organization_id: 1,
      location_id: 2,
    };
    const onSuccess = jest.fn();
    const onError = jest.fn();

    it('dispatches POST request to unassign policy endpoint', () => {
      bulkUnassignPolicy(requestBody, onSuccess, onError);

      expect(APIActions.post).toHaveBeenCalledTimes(1);
      const callArgs = APIActions.post.mock.calls[0][0];

      expect(callArgs.key).toBe(BULK_UNASSIGN_POLICY_KEY);
      expect(callArgs.url).toContain(
        '/compliance/policies/remove_policy_from_multiple_hosts'
      );
      expect(callArgs.params).toEqual({ policy: { id: '3' } });
      expect(callArgs.handleSuccess).toBe(onSuccess);
      expect(callArgs.handleError).toBe(onError);
    });

    it('includes search parameter in URL', () => {
      bulkUnassignPolicy(requestBody, onSuccess, onError);

      const callArgs = APIActions.post.mock.calls[0][0];
      const url = new URL(callArgs.url, 'http://example.com');

      expect(url.searchParams.get('search')).toBe('name ~ test');
    });

    it('has success toast message', () => {
      bulkUnassignPolicy(requestBody, onSuccess, onError);

      const callArgs = APIActions.post.mock.calls[0][0];
      const toastMessage = callArgs.successToast();

      expect(toastMessage).toContain('unassigned');
      expect(toastMessage).toContain('compliance policy');
    });

    it('has error toast handler', () => {
      bulkUnassignPolicy(requestBody, onSuccess, onError);

      const callArgs = APIActions.post.mock.calls[0][0];
      const errorMessage = 'Unassignment failed';
      const toastMessage = callArgs.errorToast({ message: errorMessage });

      expect(toastMessage).toBe(errorMessage);
    });
  });
});
