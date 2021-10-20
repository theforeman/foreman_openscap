import React from 'react';
import PropTypes from 'prop-types';
import { useQuery } from '@apollo/client';
import { useDispatch } from 'react-redux';

import { translate as __ } from 'foremanReact/common/I18n';
import { showToast } from '../../../helpers/toastHelper';

import OvalPoliciesShow from './OvalPoliciesShow';
import { encodeId } from '../../../helpers/globalIdHelper';

import ovalPolicy from '../../../graphql/queries/ovalPolicy.gql';

const WrappedOvalPoliciesShow = props => {
  const id = encodeId('ForemanOpenscap::OvalPolicy', props.match.params.id);

  const useFetchFn = componentProps =>
    useQuery(ovalPolicy, { variables: { id } });

  const renameData = data => ({ policy: data.ovalPolicy });

  return (
    <OvalPoliciesShow
      {...props}
      fetchFn={useFetchFn}
      renameData={renameData}
      resultPath="ovalPolicy"
      emptyStateTitle={__('No OVAL Policy found')}
      permissions={['view_oval_policies']}
      showToast={showToast(useDispatch())}
    />
  );
};

WrappedOvalPoliciesShow.propTypes = {
  match: PropTypes.object.isRequired,
};

export default WrappedOvalPoliciesShow;
