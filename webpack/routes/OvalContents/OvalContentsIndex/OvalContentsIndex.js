import React from 'react';
import PropTypes from 'prop-types';
import { useQuery } from '@apollo/client';
import { translate as __ } from 'foremanReact/common/I18n';

import IndexLayout from '../../../components/IndexLayout';
import OvalContentsTable from './OvalContentsTable';
import {
  useParamsToVars,
  useCurrentPagination,
} from '../../../helpers/pageParamsHelper';

import { submitDelete, prepareMutation } from '../../../helpers/mutationHelper';
import ovalContentsQuery from '../../../graphql/queries/ovalContents.gql';
import deleteOvalContentMutation from '../../../graphql/mutations/deleteOvalContent.gql';

const OvalContentsIndex = props => {
  const useFetchFn = componentProps =>
    useQuery(ovalContentsQuery, {
      variables: useParamsToVars(componentProps.history),
    });

  const renameData = data => ({
    ovalContents: data.ovalContents.nodes,
    totalCount: data.ovalContents.totalCount,
  });

  const pagination = useCurrentPagination(props.history);

  return (
    <IndexLayout pageTitle={__('OVAL Contents')}>
      <OvalContentsTable
        {...props}
        fetchFn={useFetchFn}
        renameData={renameData}
        resultPath="ovalContents.nodes"
        pagination={pagination}
        emptyStateTitle={__('No OVAL Contents found.')}
        permissions={['view_oval_contents']}
        confirmDeleteTitle={__('Delete OVAL Content')}
        submitDelete={submitDelete}
        prepareMutation={prepareMutation(
          props.history,
          props.showToast,
          ovalContentsQuery,
          'deleteOvalContent',
          __('OVAL Content successfully deleted.'),
          deleteOvalContentMutation,
          __('OVAL Content')
        )}
      />
    </IndexLayout>
  );
};

OvalContentsIndex.propTypes = {
  history: PropTypes.object.isRequired,
  showToast: PropTypes.func.isRequired,
};

export default OvalContentsIndex;
