import createOvalPolicy from '../../../../graphql/mutations/createOvalPolicy.gql';
import hostgroupsQuery from '../../../../graphql/queries/hostgroups.gql';

import { mockFactory, admin } from '../../../../testHelper';
import { decodeId } from '../../../../helpers/globalIdHelper';
import { ovalContents } from '../../../OvalContents/OvalContentsIndex/__tests__/OvalContentsIndex.fixtures';

export const newPolicyName = 'test policy';
export const newPolicyDescription = 'random description';
export const newPolicyCronline = '5 5 5 5 5';
export const newPolicyContentName = ovalContents.nodes[1].name;
export const newPolicyContentId = ovalContents.nodes[1].id;
const hostgroupId = 3;

const createPolicyMockFactory = mockFactory(
  'createOvalPolicy',
  createOvalPolicy
);
const hostgroupsMockFactory = mockFactory('hostgroups', hostgroupsQuery);

const foremanAnsiblePresent = {
  id: 'foreman_ansible_present',
  errors: null,
  failMsg: null,
  result: 'pass',
};
const rolePresent = {
  id: 'foreman_scap_client_role_present',
  errors: null,
  failMsg: null,
  result: 'pass',
};
const roleVarsPresent = {
  id: 'foreman_scap_client_vars_present',
  errors: null,
  failMsg: null,
  result: 'pass',
};
const serverVarOverriden = {
  id: 'foreman_scap_client_server_overriden',
  errors: null,
  failMsg: null,
  result: 'pass',
};
const portVarOverriden = {
  id: 'foreman_scap_client_port_overriden',
  errors: null,
  failMsg: null,
  result: 'pass',
};
const policiesVarOverriden = {
  id: 'foreman_scap_client_policies_overriden',
  errors: null,
  failMsg: null,
  result: 'pass',
};
const policyErrors = {
  id: 'oval_policy_errors',
  errors: { name: 'has already been taken' },
  failMsg: null,
  result: 'fail',
};
export const hgWithoutProxy = {
  id: 'hostgroups_without_proxy',
  errors: null,
  failMsg: 'Assign openscap_proxy to first hostgroup before proceeding.',
  result: 'fail',
};
export const roleAbsent = {
  id: 'foreman_scap_client_role_present',
  errors: null,
  failMsg:
    'theforeman.foreman_scap_client Ansible Role not found, please import it before running this action again.',
  result: 'fail',
};

const varChecks = [
  roleVarsPresent,
  serverVarOverriden,
  portVarOverriden,
  policiesVarOverriden,
];
const checkCollectionPass = [foremanAnsiblePresent, rolePresent, ...varChecks];
const checkCollectionPreconditionFail = [
  foremanAnsiblePresent,
  roleAbsent,
  ...varChecks.map(check => ({ ...check, result: 'skip' })),
];
const ovalPolicy = {
  name: newPolicyName,
  id: 'MDE6Rm9yZW1hbk9wZW5zY2FwOjpPdmFsUG9saWN5LTcw',
  period: 'custom',
  cronLine: newPolicyCronline,
  hostgroups: {
    nodes: [],
  },
};

const policyCreateSuccess = {
  checkCollection: checkCollectionPass,
  ovalPolicy,
};

const baseVariables = {
  name: newPolicyName,
  description: '',
  ovalContentId: decodeId(newPolicyContentId),
  cronLine: newPolicyCronline,
  hostgroupIds: [],
  period: 'custom',
};

export const firstHg = {
  id: 'MDE6SG9zdGdyb3VwLTM=',
  name: 'first hostgroup',
};

const successVariables = {
  ...baseVariables,
  description: newPolicyDescription,
};

export const policySuccessMock = createPolicyMockFactory(
  successVariables,
  policyCreateSuccess
);

export const policyValidationMock = createPolicyMockFactory(baseVariables, {
  checkCollection: [...checkCollectionPass, policyErrors],
  ovalPolicy,
});

export const policyPreconditionMock = createPolicyMockFactory(baseVariables, {
  checkCollection: checkCollectionPreconditionFail,
  ovalPolicy,
});

export const policyInvalidHgMock = createPolicyMockFactory(
  { ...baseVariables, hostgroupIds: [hostgroupId] },
  { checkCollection: [...checkCollectionPass, hgWithoutProxy], ovalPolicy }
);

export const hostgroupsMock = hostgroupsMockFactory(
  { search: `name ~ first` },
  { totalCount: 2, nodes: [firstHg] },
  { currentUser: admin }
);
