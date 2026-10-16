import { translate as __, sprintf } from 'foremanReact/common/I18n';

export const COMPLIANCE_STATUS = {
  COMPLIANT: 0,
  INCONCLUSIVE: 1,
  INCOMPLIANT: 2,
};

export const policyHostIds = policy => (policy.hosts || []).map(({ id }) => id);

export const toNumber = value => Number(value);

export const collectionResults = response => {
  if (Array.isArray(response)) return response;
  return response?.results || [];
};

export const uniqueIds = ids => [...new Set(ids.map(toNumber).filter(Boolean))];

export const formatHostgroupTitle = title =>
  (title || '').replace(/\//g, ' > ');

export const statusColor = status => {
  switch (status) {
    case COMPLIANCE_STATUS.COMPLIANT:
      return 'green';
    case COMPLIANCE_STATUS.INCONCLUSIVE:
      return 'orange';
    case COMPLIANCE_STATUS.INCOMPLIANT:
      return 'red';
    default:
      return 'grey';
  }
};

export const sourceForPolicy = (policy, hostDetails) => {
  const hostId = toNumber(hostDetails.id);
  const hostgroupId = toNumber(hostDetails.hostgroup_id);
  const hostgroupTitle = hostDetails.hostgroup_title || '';
  const hostgroups = policy.hostgroups || [];

  if ((policy.hosts || []).some(host => toNumber(host.id) === hostId)) {
    return { label: __('Direct host'), isDirect: true };
  }

  const assignedHostgroup = hostgroups.find(
    hostgroup => toNumber(hostgroup.id) === hostgroupId
  );
  if (assignedHostgroup) {
    return {
      label: sprintf(
        __('Host group: %s'),
        formatHostgroupTitle(assignedHostgroup.title || assignedHostgroup.name)
      ),
      isDirect: false,
    };
  }

  const inheritedHostgroup = hostgroups.reduce((bestMatch, hostgroup) => {
    const title = hostgroup.title || hostgroup.name || '';
    if (hostgroupTitle !== title && !hostgroupTitle.startsWith(`${title}/`)) {
      return bestMatch;
    }

    if (!bestMatch) {
      return hostgroup;
    }

    const bestTitle = bestMatch.title || bestMatch.name || '';
    return title.length > bestTitle.length ? hostgroup : bestMatch;
  }, null);

  if (inheritedHostgroup) {
    return {
      label: sprintf(
        __('Parent host group: %s'),
        formatHostgroupTitle(
          inheritedHostgroup.title || inheritedHostgroup.name
        )
      ),
      isDirect: false,
    };
  }

  return { label: __('Host group'), isDirect: false };
};
