import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { useQuery } from '@apollo/client';
import { translate as __, sprintf } from 'foremanReact/common/I18n';

import ConfirmModal from '../../../components/ConfirmModal';
import OvalPoliciesTable from './OvalPoliciesTable';
import { submitDelete, prepareMutation } from './OvalPoliciesIndexHelper';
import IndexLayout from '../../../components/IndexLayout';

import {
  useParamsToVars,
  useCurrentPagination,
} from '../../../helpers/pageParamsHelper';
import policiesQuery from '../../../graphql/queries/ovalPolicies.gql';

const OvalPoliciesIndex = props => {
  const pagination = useCurrentPagination(props.history);

  const [policy, setPolicy] = useState(null);

  const toggleModal = (policyToDelete = null) => {
    setPolicy(policyToDelete);
  };

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
        resultPath="ovalPolicies.nodes"
        pagination={pagination}
        emptyStateTitle={__('No OVAL Policies found')}
        permissions={['view_oval_policies']}
        toggleModal={toggleModal}
      />
      <ConfirmModal
        title={__('Delete OVAL Policy')}
        text={
          policy
            ? sprintf(__('Are you sure you want to delete %s?'), policy.name)
            : ''
        }
        onClose={toggleModal}
        isOpen={!!policy}
        onConfirm={submitDelete}
        prepareMutation={prepareMutation(
          props.history,
          toggleModal,
          props.showToast
        )}
        record={policy}
      />
    </IndexLayout>
  );
};

OvalPoliciesIndex.propTypes = {
  history: PropTypes.object.isRequired,
  showToast: PropTypes.func.isRequired,
};

export default OvalPoliciesIndex;
