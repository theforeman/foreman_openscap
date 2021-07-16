import { admin } from '../../../../testHelper';

import ovalContentsQuery from '../../../../graphql/queries/ovalContents.gql';
import deleteOvalContent from '../../../../graphql/mutations/deleteOvalContent.gql';

export const firstCall = {
  data: {
    ovalContents: {
      totalCount: 5,
      nodes: [
        {
          id: 'MDE6Rm9yZW1hbk9wZW5zY2FwOjpPdmFsQ29udGVudC0z',
          name: 'ansible OVAL content',
          url:
            'http://oval-content-source/security/data/oval/ansible-2-including-unpatched.oval.xml.bz2',
          originalFilename: '',
          meta: { canDestroy: true },
        },
        {
          id: 'MDE6Rm9yZW1hbk9wZW5zY2FwOjpPdmFsQ29udGVudC00',
          name: 'dotnet OVAL content',
          url:
            'http://oval-content-source/security/data/oval/dotnet-2.2.oval.xml.bz2',
          originalFilename: '',
          meta: { canDestroy: true },
        },
      ],
    },
    currentUser: admin,
  },
};

export const secondCall = {
  data: {
    ovalContents: {
      totalCount: 4,
      nodes: [
        {
          id: 'MDE6Rm9yZW1hbk9wZW5zY2FwOjpPdmFsQ29udGVudC00',
          name: 'dotnet OVAL content',
          url:
            'http://oval-content-source/security/data/oval/dotnet-2.2.oval.xml.bz2',
          originalFilename: '',
          meta: { canDestroy: true },
        },
        {
          id: 'MDE6Rm9yZW1hbk9wZW5zY2FwOjpPdmFsQ29udGVudC03',
          name: 'jboss OVAL content',
          url: '',
          originalFilename: 'jboss.oval.xml.bz2',
          meta: { canDestroy: true },
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
        query: deleteOvalContent,
        variables: {
          id: 'MDE6Rm9yZW1hbk9wZW5zY2FwOjpPdmFsQ29udGVudC0z',
        },
      },
      result: {
        data: {
          deleteOvalContent: {
            id: 'MDE6Rm9yZW1hbk9wZW5zY2FwOjpPdmFsQ29udGVudC0z',
            errors,
          },
        },
      },
    },
    {
      request: {
        query: ovalContentsQuery,
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
