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

const viewer = userFactory('viewer', [
  {
    __typename: 'Permission',
    id: 'MDE6UGVybWlzc2lvbi0yOTY=',
    name: 'view_oval_policies',
  },
]);

const firstPolicy = (meta = { canDestroy: true }) => ({
  __typename: 'ForemanOpenscap::OvalPolicy',
  id: 'MDE6Rm9yZW1hbk9wZW5zY2FwOjpPdmFsUG9saWN5LTE=',
  name: 'first policy',
  meta,
  ovalContent: { name: 'first content' },
});
const secondPolicy = (meta = { canDestroy: true }) => ({
  __typename: 'ForemanOpenscap::OvalPolicy',
  id: 'MDE6Rm9yZW1hbk9wZW5zY2FwOjpPdmFsUG9saWN5LTQw',
  name: 'second policy',
  meta,
  ovalContent: { name: 'second content' },
});
const policiesData = {
  totalCount: 2,
  nodes: [firstPolicy(), secondPolicy()],
};

export const mocks = policiesMockFactory(
  { first: 20, last: 20 },
  policiesData,
  { currentUser: admin }
);
export const pageParamsMocks = policiesMockFactory(
  { first: 10, last: 5 },
  {
    totalCount: 7,
    nodes: [
      {
        __typename: 'ForemanOpenscap::OvalPolicy',
        id: 'MDE6Rm9yZW1hbk9wZW5zY2FwOjpPdmFsUG9saWN5LTQx',
        name: 'sixth policy',
        meta: { canDestroy: true },
        ovalContent: { name: 'sixth content' },
      },
      {
        __typename: 'ForemanOpenscap::OvalPolicy',
        id: 'MDE6Rm9yZW1hbk9wZW5zY2FwOjpPdmFsUG9saWN5LTQy',
        name: 'seventh policy',
        meta: { canDestroy: true },
        ovalContent: { name: 'seventh content' },
      },
    ],
  },
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
  {
    errors: [{ message: 'Something very bad happened.', path: 'base' }],
    currentUser: admin,
  }
);
export const viewerMocks = policiesMockFactory(
  { first: 20, last: 20 },
  policiesData,
  { currentUser: viewer }
);
export const unauthorizedMocks = policiesMockFactory(
  { first: 20, last: 20 },
  policiesData,
  { currentUser: intruder }
);
export const noDeleteMocks = policiesMockFactory(
  { first: 20, last: 20 },
  {
    totalCount: 2,
    nodes: [
      firstPolicy({ canDestroy: false }),
      secondPolicy({ canDestroy: false }),
    ],
  },
  { currentUser: admin }
);
