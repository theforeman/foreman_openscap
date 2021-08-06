import ovalPoliciesSetupQuery from '../../../../graphql/queries/ovalPoliciesSetup.gql';
import { mockFactory } from '../../../../testHelper';

const ovalSetupFactory = mockFactory(
  'ovalPoliciesSetup',
  ovalPoliciesSetupQuery
);

const foremanAnsiblePresent = {
  id: 'MDE6T3ZhbFBvbGljeUNoZWNrLWZvcmVtYW5fYW5zaWJsZV9wcmVzZW50',
  title: 'Is foreman_ansible present?',
  result: 'pass',
  failMsg: null,
  errors: null,
  __typename: 'OvalPolicyCheck',
};
const rolePresent = {
  id: 'MDE6T3ZhbFBvbGljeUNoZWNrLWZvcmVtYW5fc2NhcF9jbGllbnRfcm9sZV9wcmVzZW50',
  title: 'Is theforeman.foreman_scap_client present?',
  result: 'pass',
  failMsg: null,
  errors: null,
  __typename: 'OvalPolicyCheck',
};
const roleVarsPresent = {
  id: 'MDE6T3ZhbFBvbGljeUNoZWNrLWZvcmVtYW5fc2NhcF9jbGllbnRfdmFyc19wcmVzZW50',
  title: 'Are required variables for theforeman.foreman_scap_client present?',
  result: 'pass',
  failMsg: null,
  errors: null,
  __typename: 'OvalPolicyCheck',
};
const serverVarOverriden = {
  id:
    'MDE6T3ZhbFBvbGljeUNoZWNrLWZvcmVtYW5fc2NhcF9jbGllbnRfc2VydmVyX292ZXJyaWRlbg==',
  title: 'Is foreman_scap_client_server param set to be overriden?',
  result: 'pass',
  failMsg: null,
  errors: null,
  __typename: 'OvalPolicyCheck',
};
const portVarOverriden = {
  id:
    'MDE6T3ZhbFBvbGljeUNoZWNrLWZvcmVtYW5fc2NhcF9jbGllbnRfcG9ydF9vdmVycmlkZW4=',
  title: 'Is foreman_scap_client_port param set to be overriden?',
  result: 'pass',
  failMsg: null,
  errors: null,
  __typename: 'OvalPolicyCheck',
};
const policiesVarOverriden = {
  id:
    'MDE6T3ZhbFBvbGljeUNoZWNrLWZvcmVtYW5fc2NhcF9jbGllbnRfcG9saWNpZXNfb3ZlcnJpZGVu',
  title: 'Is foreman_scap_client_oval_policies param set to be overriden?',
  result: 'pass',
  failMsg: null,
  errors: null,
  __typename: 'OvalPolicyCheck',
};
export const roleAbsent = {
  ...rolePresent,
  result: 'fail',
  failMsg:
    'theforeman.foreman_scap_client Ansible Role not found, please import it before running this action again.',
};
const varChecks = [
  roleVarsPresent,
  serverVarOverriden,
  portVarOverriden,
  policiesVarOverriden,
];
const checkCollectionPass = [foremanAnsiblePresent, rolePresent, ...varChecks];
const checkCollectionFail = [
  foremanAnsiblePresent,
  roleAbsent,
  ...varChecks.map(check => ({ ...check, result: 'skip' })),
];

export const passingChecksMock = ovalSetupFactory(null, checkCollectionPass);
export const failingChecksMock = ovalSetupFactory(null, checkCollectionFail);
