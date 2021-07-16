import policiesQuery from '../../../../graphql/queries/ovalPolicies.gql';
import deleteOvalPolicy from '../../../../graphql/mutations/deleteOvalPolicy.gql';

import { admin } from '../../../../testHelper';

export const firstCall = {
  data: {
    ovalPolicies: {
      totalCount: 5,
      nodes: [
        {
          __typename: 'ForemanOpenscap::OvalPolicy',
          id: 'MDE6Rm9yZW1hbk9wZW5zY2FwOjpPdmFsUG9saWN5LTQz',
          name: 'first policy',
          meta: { canDestroy: true },
          ovalContent: { name: 'foo' },
        },
        {
          __typename: 'ForemanOpenscap::OvalPolicy',
          id: 'MDE6Rm9yZW1hbk9wZW5zY2FwOjpPdmFsUG9saWN5LTQ0',
          name: 'second policy',
          meta: { canDestroy: true },
          ovalContent: { name: 'foo' },
        },
      ],
    },
    currentUser: admin,
  },
};

export const secondCall = {
  data: {
    ovalPolicies: {
      totalCount: 4,
      nodes: [
        {
          id: 'MDE6Rm9yZW1hbk9wZW5zY2FwOjpPdmFsUG9saWN5LTQ0',
          name: 'second policy',
          meta: { canDestroy: true },
          ovalContent: { name: 'foo' },
        },
        {
          id: 'MDE6Rm9yZW1hbk9wZW5zY2FwOjpPdmFsUG9saWN5LTQ1',
          name: 'third policy',
          meta: { canDestroy: true },
          ovalContent: { name: 'foo' },
        },
      ],
    },
    currentUser: admin,
  },
};

export const deleteMockFactory = (first, second, errors = null) => {
  let called = false;

  const deleteMocks = [
    {
      request: {
        query: deleteOvalPolicy,
        variables: {
          id: 'MDE6Rm9yZW1hbk9wZW5zY2FwOjpPdmFsUG9saWN5LTQz',
        },
      },
      result: {
        data: {
          deleteOvalPolicy: {
            __typename: 'ForemanOpenscap::OvalPolicy',
            id: 'MDE6Rm9yZW1hbk9wZW5zY2FwOjpPdmFsUG9saWN5LTQz',
            errors,
          },
        },
      },
    },
    {
      request: {
        query: policiesQuery,
        variables: {
          first: 2,
          last: 2,
        },
      },
      newData: () => {
        if (called && !errors) {
          return second;
        } else if (called && errors) {
          return first;
        }
        called = true;
        return first;
      },
    },
  ];
  return deleteMocks;
};
