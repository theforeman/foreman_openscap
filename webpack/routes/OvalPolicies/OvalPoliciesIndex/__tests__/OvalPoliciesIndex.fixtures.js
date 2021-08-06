import policiesQuery from '../../../../graphql/queries/ovalPolicies.gql';
import { ovalPoliciesPath } from '../../../../helpers/pathsHelper';
import {
  mockFactory,
  admin,
  intruder,
  userFactory,
} from '../../../../testHelper';

const policiesMockFactory = mockFactory('ovalPolicies', policiesQuery);

export const pushMock = jest.fn();

export const pageParamsHistoryMock = {
  location: {
    search: '?page=2&perPage=5',
    pathname: ovalPoliciesPath,
  },
  push: pushMock,
};

const policiesMocks = {
  totalCount: 2,
  nodes: [
    {
      __typename: 'ForemanOpenscap::OvalPolicy',
      id: 'abc',
      name: 'first policy',
      ovalContent: { name: 'first content' },
    },
    {
      __typename: 'ForemanOpenscap::OvalPolicy',
      id: 'xyz',
      name: 'second policy',
      ovalContent: { name: 'second content' },
    },
  ],
};

const pagedPoliciesMocks = {
  totalCount: 7,
  nodes: [
    {
      __typename: 'ForemanOpenscap::OvalPolicy',
      id: 'xyz',
      name: 'sixth policy',
      ovalContent: { name: 'sixth content' },
    },
    {
      __typename: 'ForemanOpenscap::OvalPolicy',
      id: 'abc',
      name: 'seventh policy',
      ovalContent: { name: 'seventh content' },
    },
  ],
};

const viewer = userFactory('viewer', [
  {
    __typename: 'Permission',
    id: 'MDE6UGVybWlzc2lvbi0yOTY=',
    name: 'view_oval_policies',
  },
]);

export const mocks = policiesMockFactory(
  { first: 20, last: 20 },
  policiesMocks,
  { currentUser: admin }
);
export const pageParamsMocks = policiesMockFactory(
  { first: 10, last: 5 },
  pagedPoliciesMocks,
  { currentUser: admin }
);
export const emptyMocks = policiesMockFactory(
  { first: 20, last: 20 },
  { totalCount: 0, nodes: [] },
  { currentUser: admin }
);
export const errorMocks = policiesMockFactory(
  { first: 20, last: 20 },
  { totalCount: 0, nodes: [] },
  { errors: [{ message: 'Something very bad happened.' }], currentUser: admin }
);
export const viewerMocks = policiesMockFactory(
  { first: 20, last: 20 },
  policiesMocks,
  { currentUser: viewer }
);
export const unauthorizedMocks = policiesMockFactory(
  { first: 20, last: 20 },
  policiesMocks,
  { currentUser: intruder }
);
