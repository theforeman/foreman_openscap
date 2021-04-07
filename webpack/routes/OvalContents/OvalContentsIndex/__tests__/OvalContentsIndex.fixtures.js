import ovalContentsQuery from '../../../../graphql/queries/ovalContents.gql';
import { ovalContentsPath } from '../../../../helpers/pathsHelper';
import { mockFactory } from '../../../../testHelper';

const ovalContentMockFactory = mockFactory('ovalContents', ovalContentsQuery);

export const mocks = [
  {
    request: {
      query: ovalContentsQuery,
      variables: {
        first: 20,
        last: 20,
      },
    },
    result: {
      data: {
        ovalContents: {
          totalCount: 4,
          nodes: [
            {
              id: 'abc',
              name: 'ansible OVAL content',
              url:
                'http://oval-content-source/security/data/oval/ansible-2-including-unpatched.oval.xml.bz2',
              originalFilename: '',
            },
            {
              id: 'bcd',
              name: 'dotnet OVAL content',
              url:
                'http://oval-content-source/security/data/oval/dotnet-2.2.oval.xml.bz2',
              originalFilename: '',
            },
            {
              id: 'cde',
              name: 'jboss OVAL content',
              url: '',
              originalFilename: 'jboss.oval.xml.bz2',
            },
            {
              id: 'def',
              name: 'openshift OVAL content',
              url: '',
              originalFilename: 'openshift.oval.xml.bz2',
            },
          ],
        },
      },
    },
  },
];

export const paginatedMocks = [
  {
    request: {
      query: ovalContentsQuery,
      variables: {
        first: 10,
        last: 5,
      },
    },
    result: {
      data: {
        ovalContents: {
          totalCount: 7,
          nodes: [
            {
              id: 'bcd',
              name: 'dotnet OVAL content',
              url:
                'http://oval-content-source/security/data/oval/dotnet-2.2.oval.xml.bz2',
              originalFilename: '',
            },
            {
              id: 'def',
              name: 'openshift OVAL content',
              url: '',
              originalFilename: 'openshift.oval.xml.bz2',
            },
          ],
        },
      },
    },
  },
];

export const emptyMocks = ovalContentMockFactory(
  { first: 20, last: 20 },
  { totalCount: 0, nodes: [] }
);
export const errorMocks = ovalContentMockFactory(
  { first: 20, last: 20 },
  { totalCount: 0, nodes: [] },
  [{ message: 'Something very bad happened.' }]
);

export const pushMock = jest.fn();

export const pagePaginationHistoryMock = {
  location: {
    search: '?page=2&perPage=5',
    pathname: ovalContentsPath,
  },
  push: pushMock,
};
