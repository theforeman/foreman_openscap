import policiesQuery from '../../../../graphql/queries/ovalPolicies.gql';
import { ovalPoliciesPath } from '../../../../helpers/pathsHelper';
import { mockFactory } from '../../../../testHelper';

const policiesMockFactory = mockFactory('ovalPolicies', policiesQuery);

export const pushMock = jest.fn();

export const pageParamsHistoryMock = {
  location: {
    search: '?page=2&perPage=5',
    pathname: ovalPoliciesPath,
  },
  push: pushMock,
};

const firstPolicy = (meta = { canDestroy: true }) => ({
  id: 'MDE6Rm9yZW1hbk9wZW5zY2FwOjpPdmFsUG9saWN5LTE=',
  name: 'first policy',
  meta,
  ovalContent: { name: 'first content' },
});
const secondPolicy = (meta = { canDestroy: true }) => ({
  id: 'MDE6Rm9yZW1hbk9wZW5zY2FwOjpPdmFsUG9saWN5LTQw',
  name: 'second policy',
  meta,
  ovalContent: { name: 'second content' },
});

export const mocks = policiesMockFactory(
  { first: 20, last: 20 },
  {
    totalCount: 2,
    nodes: [firstPolicy(), secondPolicy()],
  }
);
export const pageParamsMocks = policiesMockFactory(
  { first: 10, last: 5 },
  {
    totalCount: 7,
    nodes: [
      {
        id: 'MDE6Rm9yZW1hbk9wZW5zY2FwOjpPdmFsUG9saWN5LTQx',
        name: 'sixth policy',
        meta: { canDestroy: true },
        ovalContent: { name: 'sixth content' },
      },
      {
        id: 'MDE6Rm9yZW1hbk9wZW5zY2FwOjpPdmFsUG9saWN5LTQy',
        name: 'seventh policy',
        meta: { canDestroy: true },
        ovalContent: { name: 'seventh content' },
      },
    ],
  }
);
export const emptyMocks = policiesMockFactory(
  { first: 20, last: 20 },
  { totalCount: 0, nodes: [] }
);
export const errorMocks = policiesMockFactory(
  { first: 20, last: 20 },
  { totalCount: 0, nodes: [] },
  [{ message: 'Something very bad happened.' }]
);
export const noDeleteMocks = policiesMockFactory(
  { first: 20, last: 20 },
  {
    totalCount: 2,
    nodes: [
      firstPolicy({ canDestroy: false }),
      secondPolicy({ canDestroy: false }),
    ],
  }
);
