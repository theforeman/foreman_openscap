import { mockFactory } from '../../../../testHelper';
import updateOvalPolicyMutation from '../../../../graphql/mutations/updateOvalPolicy.gql';
import { ovalPolicy } from './OvalPoliciesShow.fixtures';

const updateOvalPolicyMockFactory = mockFactory(
  'updateOvalPolicy',
  updateOvalPolicyMutation
);

export const updatedName = 'updated policy name';

const variables = {
  id: ovalPolicy.id,
  name: updatedName,
  cronLine: ovalPolicy.cronLine,
  description: ovalPolicy.description,
};
const responsePolicy = {
  ovalPolicy: {
    __typename: 'ForemanOpenscap::OvalPolicy',
    id: ovalPolicy.id,
    name: updatedName,
    description: ovalPolicy.description,
    cronLine: ovalPolicy.cronLine,
    period: ovalPolicy.period,
    dayOfMonth: ovalPolicy.dayOfMonth,
    weekday: ovalPolicy.weekday,
  },
  errors: [],
};
const scheduleUpdatedPolicy = {
  ovalPolicy: {
    ...ovalPolicy,
    period: 'monthly',
    dayOfMonth: 14,
    weekday: null,
  },
  errors: [],
};

export const policyUpdateScheduleMock = updateOvalPolicyMockFactory(
  { id: ovalPolicy.id, period: 'monthly', dayOfMonth: '14' },
  scheduleUpdatedPolicy
);

export const policyUpdateMock = updateOvalPolicyMockFactory(
  variables,
  responsePolicy
);

export const policyUpdateErrorMock = updateOvalPolicyMockFactory(
  variables,
  responsePolicy,
  { errors: [{ message: 'This is an unexpected failure.' }] }
);

export const policyUpdateValidationMock = updateOvalPolicyMockFactory(
  variables,
  {
    ovalPolicy,
    errors: [
      { path: ['attributes', 'name'], message: 'has already been taken' },
    ],
  }
);
