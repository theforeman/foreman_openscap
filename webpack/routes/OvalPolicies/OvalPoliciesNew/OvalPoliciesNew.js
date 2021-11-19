import React from 'react';
import { useQuery } from '@apollo/client';
import { translate as __ } from 'foremanReact/common/I18n';
import IndexLayout from '../../../components/IndexLayout';

import ovalContentsQuery from '../../../graphql/queries/ovalContents.gql';
import NewOvalPolicyForm from './NewOvalPolicyForm';

const OvalPoliciesNew = props => {
  const useFetchFn = () => useQuery(ovalContentsQuery);

  const renameData = data => ({
    ovalContents: data.ovalContents.nodes,
  });

  return (
    <IndexLayout pageTitle={__('Create OVAL Policy')}>
      <NewOvalPolicyForm
        fetchFn={useFetchFn}
        renameData={renameData}
        resultPath="ovalContents.nodes"
        emptyStateTitle={__('No OVAL Content found')}
        emptyStateBody={__(
          'OVAL Content is required to create OVAL Policy. Please create one before proceeding.'
        )}
        {...props}
      />
    </IndexLayout>
  );
};

export default OvalPoliciesNew;
