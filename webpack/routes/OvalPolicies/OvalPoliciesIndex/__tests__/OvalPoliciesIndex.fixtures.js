import policiesQuery from '../../../../graphql/queries/ovalPolicies.gql';
import { ovalPoliciesPath } from '../../../../helpers/pathsHelper';

const mockFactory = (resultName, query) => (
  variables,
  modelResults,
  errors = []
) => {
  const mock = {
    request: {
      query,
      variables,
    },
    result: {
      data: {
        [resultName]: modelResults,
      },
    },
  };

  if (errors.length !== 0) {
    mock.result.errors = errors;
  }

  return [mock];
};

const policiesMockFactory = mockFactory('ovalPolicies', policiesQuery);

export const pushMock = jest.fn();

export const pageParamsHistoryMock = {
  location: {
    search: '?page=2&perPage=5',
    pathname: ovalPoliciesPath,
  },
  push: pushMock,
};

export const mocks = policiesMockFactory(
  { first: 20, last: 20 },
  {
    totalCount: 2,
    nodes: [
      {
        id: 'abc',
        name: 'first policy',
        ovalContent: { name: 'first content' },
      },
      {
        id: 'xyz',
        name: 'second policy',
        ovalContent: { name: 'second content' },
      },
    ],
  }
);
export const pageParamsMocks = policiesMockFactory(
  { first: 10, last: 5 },
  {
    totalCount: 7,
    nodes: [
      {
        id: 'xyz',
        name: 'sixth policy',
        ovalContent: { name: 'sixth content' },
      },
      {
        id: 'abc',
        name: 'seventh policy',
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
