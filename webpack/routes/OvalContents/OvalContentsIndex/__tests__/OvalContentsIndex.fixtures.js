import ovalContentsQuery from '../../../../graphql/queries/ovalContents.gql';
import { ovalContentsPath } from '../../../../helpers/pathsHelper';
import { mockFactory } from '../../../../testHelper';

const ovalContentMockFactory = mockFactory('ovalContents', ovalContentsQuery);

const firstContent = (meta = { canDestroy: true }) => ({
  id: '"MDE6Rm9yZW1hbk9wZW5zY2FwOjpPdmFsQ29udGVudC0z"',
  name: 'ansible OVAL content',
  url:
    'http://oval-content-source/security/data/oval/ansible-2-including-unpatched.oval.xml.bz2',
  originalFilename: '',
  meta,
});

const secondContent = (meta = { canDestroy: true }) => ({
  id: 'MDE6Rm9yZW1hbk9wZW5zY2FwOjpPdmFsQ29udGVudC00',
  name: 'dotnet OVAL content',
  url: 'http://oval-content-source/security/data/oval/dotnet-2.2.oval.xml.bz2',
  originalFilename: '',
  meta,
});

const thirdContent = (meta = { canDestroy: true }) => ({
  id: 'MDE6Rm9yZW1hbk9wZW5zY2FwOjpPdmFsQ29udGVudC03',
  name: 'jboss OVAL content',
  url: '',
  originalFilename: 'jboss.oval.xml.bz2',
  meta,
});

const fourthContent = (meta = { canDestroy: true }) => ({
  id: 'MDE6Rm9yZW1hbk9wZW5zY2FwOjpPdmFsQ29udGVudC0zMw==',
  name: 'openshift OVAL content',
  url: '',
  originalFilename: 'openshift.oval.xml.bz2',
  meta,
});

export const mocks = ovalContentMockFactory(
  { first: 20, last: 20 },
  {
    totalCount: 4,
    nodes: [firstContent(), secondContent(), thirdContent(), fourthContent()],
  }
);

export const paginatedMocks = ovalContentMockFactory(
  { first: 10, last: 5 },
  { totalCount: 7, nodes: [secondContent(), fourthContent()] }
);

export const emptyMocks = ovalContentMockFactory(
  { first: 20, last: 20 },
  { totalCount: 0, nodes: [] }
);
export const errorMocks = ovalContentMockFactory(
  { first: 20, last: 20 },
  { totalCount: 0, nodes: [] },
  [{ message: 'Something very bad happened.' }]
);

export const noDeleteMocks = ovalContentMockFactory(
  { first: 20, last: 20 },
  {
    totalCount: 2,
    nodes: [
      firstContent({ canDestroy: false }),
      secondContent({ canDestroy: false }),
    ],
  }
);

export const pushMock = jest.fn();

export const pagePaginationHistoryMock = {
  location: {
    search: '?page=2&perPage=5',
    pathname: ovalContentsPath,
  },
  push: pushMock,
};
