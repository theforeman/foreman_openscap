import { mockFactory, admin, intruder, viewer } from '../../../../testHelper';
import ovalPolicyQuery from '../../../../graphql/queries/ovalPolicy.gql';
import cvesQuery from '../../../../graphql/queries/cves.gql';
import hostgroupsQuery from '../../../../graphql/queries/hostgroups.gql';

const policyDetailMockFactory = mockFactory('ovalPolicy', ovalPolicyQuery);
const cvesMockFactory = mockFactory('cves', cvesQuery);
const hostgroupsMockFactory = mockFactory('hostgroups', hostgroupsQuery);

export const ovalPolicy = {
  __typename: 'ForemanOpenscap::OvalPolicy',
  id: 'MDE6Rm9yZW1hbk9wZW5zY2FwOjpPdmFsUG9saWN5LTM=',
  name: 'Third policy',
  period: 'weekly',
  cronLine: null,
  weekday: 'tuesday',
  dayOfMonth: null,
  description: 'A very strict policy',
  meta: {
    canEdit: true,
  },
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

const noEditPolicy = { ...ovalPolicy, meta: { canEdit: false } };

const cvesResult = {
  totalCount: 1,
  nodes: [
    {
      __typename: 'ForemanOpenscap::Cve',
      id: 'MDE6Rm9yZW1hbk9wZW5zY2FwOjpDdmUtMjY3',
      refId: 'CVE-2020-14365',
      refUrl: 'https://access.redhat.com/security/cve/CVE-2020-14365',
      definitionId: 'oval:com.redhat.rhsa:def:20203601',
      hasErrata: true,
      hosts: {
        nodes: [
          {
            __typename: 'Host',
            id: 'MDE6SG9zdC0z',
            name: 'centos-random.example.com',
          },
        ],
      },
    },
  ],
};

const hostgroupsResult = {
  totalCount: 2,
  nodes: [
    {
      id: 'MDE6SG9zdGdyb3VwLTQ=',
      name: 'first hostgroup',
    },
    {
      id: 'MDE6SG9zdGdyb3VwLTEy',
      name: 'second hostgroup',
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
export const policyHostgroupsMock = hostgroupsMockFactory(
  { search: `oval_policy_id = ${ovalPolicyId}`, first: 5, last: 5 },
  hostgroupsResult,
  { currentUser: admin }
);
export const policyHostgroupsDeniedMock = hostgroupsMockFactory(
  { search: `oval_policy_id = ${ovalPolicyId}`, first: 5, last: 5 },
  { totalCount: 0, nodes: [] },
  { currentUser: intruder }
);
export const policyEditPermissionsMock = policyDetailMockFactory(
  { id: ovalPolicy.id },
  noEditPolicy,
  { currentUser: viewer }
);
