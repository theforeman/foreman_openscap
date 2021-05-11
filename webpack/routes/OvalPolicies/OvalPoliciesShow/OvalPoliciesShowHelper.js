import { decodeId } from '../../../helpers/globalIdHelper';
import { addSearch } from '../../../helpers/pageParamsHelper';
import { newJobPath } from '../../../helpers/pathsHelper';

export const policySchedule = policy => {
  switch (policy.period) {
    case 'weekly':
      return `Weekly, on ${policy.weekday}`;
    case 'monthly':
      return `Monthly, day of month: ${policy.dayOfMonth}`;
    case 'custom':
      return `Custom cron: ${policy.cronLine}`;
    default:
      return 'Unknown schedule';
  }
};

const targetingScopedSearchQuery = policy => {
  const hgIds = policy.hostgroups.nodes.reduce((memo, hg) => {
    const ids = [decodeId(hg)].concat(hg.descendants.nodes.map(decodeId));
    return ids.reduce(
      (acc, id) => (acc.includes(id) ? acc : [...acc, id]),
      memo
    );
  }, []);

  if (hgIds.length === 0) {
    return '';
  }

  return `hostgroup_id ^ (${hgIds.join(' ')})`;
};

export const newJobFormPath = (policy, policyId) =>
  addSearch(newJobPath, {
    feature: 'foreman_openscap_run_oval_scans',
    host_ids: targetingScopedSearchQuery(policy),
    'inputs[oval_policies]': policyId,
  });
