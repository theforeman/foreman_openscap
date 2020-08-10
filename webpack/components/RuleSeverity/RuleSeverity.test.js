import { testComponentSnapshotsWithFixtures } from '@theforeman/test';

import RuleSeverity from './index';

const levels = ['Low', 'Medium', 'High', 'Critical', 'foo'];

const fixtures = levels.reduce((memo, level) => {
  memo[`should render for ${level} severity`] = { severity: level };
  return memo;
}, {});

describe('RuleSeverity', () =>
  testComponentSnapshotsWithFixtures(RuleSeverity, fixtures));
