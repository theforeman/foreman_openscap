import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';

import { useQuery } from '@apollo/client';

import HostgroupsTable from './HostgroupsTable';

import hostgroups from '../../../graphql/queries/hostgroups.gql';
import {
  useParamsToVars,
  useCurrentPagination,
} from '../../../helpers/pageParamsHelper';

const HostgroupsTab = props => {
  const useFetchFn = componentProps =>
    useQuery(hostgroups, {
      variables: {
        search: `oval_policy_id = ${componentProps.match.params.id}`,
        ...useParamsToVars(componentProps.history),
      },
    });

  const renameData = data => ({
    hostgroups: data.hostgroups.nodes,
    totalCount: data.hostgroups.totalCount,
  });

  const pagination = useCurrentPagination(props.history);

  return (
    <HostgroupsTable
      {...props}
      fetchFn={useFetchFn}
      renameData={renameData}
      resultPath="hostgroups.nodes"
      pagination={pagination}
      emptyStateTitle={__('No Hostgroups found.')}
      permissions={['view_hostgroups']}
    />
  );
};

HostgroupsTab.propTypes = {
  match: PropTypes.object.isRequired,
  history: PropTypes.object.isRequired,
};

export default HostgroupsTab;
