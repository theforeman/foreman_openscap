import { mockFactory, admin, intruder } from '../../../../testHelper';
import ovalPolicyQuery from '../../../../graphql/queries/ovalPolicy.gql';
import cvesQuery from '../../../../graphql/queries/cves.gql';

const policyDetailMockFactory = mockFactory('ovalPolicy', ovalPolicyQuery);
const cvesMockFactory = mockFactory('cves', cvesQuery);

const ovalPolicy = {
  id: 'MDE6Rm9yZW1hbk9wZW5zY2FwOjpPdmFsUG9saWN5LTM=',
  name: 'Third policy',
  period: 'weekly',
  cronLine: null,
  weekday: 'tuesday',
  dayOfMonth: null,
  description: 'A very strict policy',
  hostgroups: {
    nodes: [
      {
        id: 'MDE6SG9zdGdyb3VwLTQ=',
        name: 'oval hg',
        descendants: {
          nodes: [
            { id: 'MDE6SG9zdGdyb3VwLTEw' },
            { id: 'MDE6SG9zdGdyb3VwLTEy' },
            { id: 'MDE6SG9zdGdyb3VwLTEx' },
          ],
        },
      },
    ],
  },
};

const cvesResult = {
  totalCount: 1,
  nodes: [
    {
      id: 'MDE6Rm9yZW1hbk9wZW5zY2FwOjpDdmUtMjY3',
      refId: 'CVE-2020-14365',
      refUrl: 'https://access.redhat.com/security/cve/CVE-2020-14365',
      definitionId: 'oval:com.redhat.rhsa:def:20203601',
      hasErrata: true,
      hosts: {
        nodes: [
          {
            id: 'MDE6SG9zdC0z',
            name: 'centos-random.example.com',
          },
        ],
      },
    },
  ],
};

export const ovalPolicyId = 3;

export const pushMock = jest.fn();

export const historyMock = {
  location: {
    search: '',
  },
  push: pushMock,
};

export const historyWithSearch = {
  location: {
    search: '?page=1&perPage=5',
  },
};

export const policyDetailMock = policyDetailMockFactory(
  { id: ovalPolicy.id },
  ovalPolicy,
  { currentUser: admin }
);

export const policyUnauthorizedMock = policyDetailMockFactory(
  { id: ovalPolicy.id },
  ovalPolicy,
  { currentUser: intruder }
);

export const policyCvesMock = cvesMockFactory(
  { search: `oval_policy_id = ${ovalPolicyId}`, first: 5, last: 5 },
  cvesResult,
  { currentUser: admin }
);
