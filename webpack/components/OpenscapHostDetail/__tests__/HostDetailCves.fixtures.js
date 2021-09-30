import { createMemoryHistory } from 'history';
import { mockFactory, admin } from '../../../testHelper';
import cvesQuery from '../../../graphql/queries/cves.gql';
import { cvesResult } from '../../../routes/OvalPolicies/OvalPoliciesShow/__tests__/OvalPoliciesShow.fixtures';

const cvesMockFactory = mockFactory('cves', cvesQuery);

export const hostId = 3;
export const response = { id: hostId };
export const status = 'RESOLVED';
export const location = { pathname: '/Compliance/cves', search: '', hash: '' };
export const router = { push: jest.fn() };
export const match = {};
const history = createMemoryHistory();
history.location = location;
export { history };

export const cvesMock = cvesMockFactory(
  { search: `host_id = ${hostId}`, first: 20, last: 20 },
  cvesResult,
  { currentUser: admin }
);
