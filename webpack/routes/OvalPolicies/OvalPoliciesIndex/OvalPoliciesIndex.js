import React from 'react';
import PropTypes from 'prop-types';
import { useQuery } from '@apollo/client';
import { translate as __ } from 'foremanReact/common/I18n';

import OvalPoliciesTable from './OvalPoliciesTable';
import IndexLayout from '../../../components/IndexLayout';

import {
  useParamsToVars,
  useCurrentPagination,
} from '../../../helpers/pageParamsHelper';
import policiesQuery from '../../../graphql/queries/ovalPolicies.gql';

const OvalPoliciesIndex = props => {
  const pagination = useCurrentPagination(props.history);

  const useFetchFn = componentProps =>
    useQuery(policiesQuery, {
      variables: useParamsToVars(componentProps.history),
    });

  const renameData = data => ({
    policies: data.ovalPolicies.nodes,
    totalCount: data.ovalPolicies.totalCount,
  });

  return (
    <IndexLayout pageTitle={__('OVAL Policies')}>
      <OvalPoliciesTable
        {...props}
        fetchFn={useFetchFn}
        renameData={renameData}
        queryName="ovalPolicies"
        pagination={pagination}
        emptyStateTitle={__('No OVAL Policies found')}
      />
    </IndexLayout>
  );
};

OvalPoliciesIndex.propTypes = {
  history: PropTypes.object.isRequired,
};

export default OvalPoliciesIndex;
