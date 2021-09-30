import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';

import { useQuery } from '@apollo/client';

import CvesTable from './CvesTable';

import cves from '../../../graphql/queries/cves.gql';
import {
  useParamsToVars,
  useCurrentPagination,
} from '../../../helpers/pageParamsHelper';

const CvesTab = props => {
  const useFetchFn = componentProps =>
    useQuery(cves, {
      variables: {
        search: `${props.searchKey} = ${props.id}`,
        ...useParamsToVars(componentProps.history),
      },
    });

  const renameData = data => ({
    cves: data.cves.nodes,
    totalCount: data.cves.totalCount,
  });

  const pagination = useCurrentPagination(props.history);

  return (
    <CvesTable
      {...props}
      fetchFn={useFetchFn}
      renameData={renameData}
      resultPath="cves.nodes"
      pagination={pagination}
      emptyStateTitle={__('No CVEs found.')}
      permissions={['view_oval_policies']}
    />
  );
};

CvesTab.propTypes = {
  id: PropTypes.number.isRequired,
  match: PropTypes.object.isRequired,
  history: PropTypes.object.isRequired,
  searchKey: PropTypes.string.isRequired,
};

export default CvesTab;
