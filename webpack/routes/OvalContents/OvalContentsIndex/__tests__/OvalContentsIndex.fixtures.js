import ovalContentsQuery from '../../../../graphql/queries/ovalContents.gql';
import { ovalContentsPath } from '../../../../helpers/pathsHelper';
import {
  mockFactory,
  admin,
  intruder,
  userFactory,
} from '../../../../testHelper';

const ovalContentMockFactory = mockFactory('ovalContents', ovalContentsQuery);

const ovalContents = {
  totalCount: 4,
  nodes: [
    {
      __typename: 'ForemanOpenscap::OvalContent',
      id: 'abc',
      name: 'ansible OVAL content',
      url:
        'http://oval-content-source/security/data/oval/ansible-2-including-unpatched.oval.xml.bz2',
      originalFilename: '',
    },
    {
      __typename: 'ForemanOpenscap::OvalContent',
      id: 'bcd',
      name: 'dotnet OVAL content',
      url:
        'http://oval-content-source/security/data/oval/dotnet-2.2.oval.xml.bz2',
      originalFilename: '',
    },
    {
      __typename: 'ForemanOpenscap::OvalContent',
      id: 'cde',
      name: 'jboss OVAL content',
      url: '',
      originalFilename: 'jboss.oval.xml.bz2',
    },
    {
      __typename: 'ForemanOpenscap::OvalContent',
      id: 'def',
      name: 'openshift OVAL content',
      url: '',
      originalFilename: 'openshift.oval.xml.bz2',
    },
  ],
};

const paginatedOvalContents = {
  totalCount: 7,
  nodes: [
    {
      __typename: 'ForemanOpenscap::OvalContent',
      id: 'bcd',
      name: 'dotnet OVAL content',
      url:
        'http://oval-content-source/security/data/oval/dotnet-2.2.oval.xml.bz2',
      originalFilename: '',
    },
    {
      __typename: 'ForemanOpenscap::OvalContent',
      id: 'def',
      name: 'openshift OVAL content',
      url: '',
      originalFilename: 'openshift.oval.xml.bz2',
    },
  ],
};

const viewer = userFactory('viewer', [
  {
    __typename: 'Permission',
    id: 'MDE6UGVybWlzc2lvbi0yOTY=',
    name: 'view_oval_contents',
  },
]);

export const mocks = ovalContentMockFactory(
  { first: 20, last: 20 },
  ovalContents,
  { currentUser: admin }
);

export const paginatedMocks = ovalContentMockFactory(
  { first: 10, last: 5 },
  paginatedOvalContents,
  { currentUser: admin }
);

export const emptyMocks = ovalContentMockFactory(
  { first: 20, last: 20 },
  { totalCount: 0, nodes: [] },
  { currentUser: admin }
);
export const errorMocks = ovalContentMockFactory(
  { first: 20, last: 20 },
  { totalCount: 0, nodes: [] },
  { errors: [{ message: 'Something very bad happened.' }], currentUser: admin }
);

export const viewerMocks = ovalContentMockFactory(
  { first: 20, last: 20 },
  ovalContents,
  { currentUser: viewer }
);

export const unauthorizedMocks = ovalContentMockFactory(
  { first: 20, last: 20 },
  ovalContents,
  { currentUser: intruder }
);

export const pushMock = jest.fn();

export const pagePaginationHistoryMock = {
  location: {
    search: '?page=2&perPage=5',
    pathname: ovalContentsPath,
  },
  push: pushMock,
};
