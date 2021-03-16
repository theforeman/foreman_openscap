import { useMutation } from '@apollo/client';
import { translate as __, sprintf } from 'foremanReact/common/I18n';

import {
  useCurrentPagination,
  pageToVars,
} from '../../../helpers/pageParamsHelper';

import deleteOvalPolicyMutation from '../../../graphql/mutations/deleteOvalPolicy.gql';
import policiesQuery from '../../../graphql/queries/ovalPolicies.gql';

const formatError = error =>
  sprintf(
    __('There was a following error when deleting OVAL policy: %s'),
    error
  );

const joinErrors = errors => errors.map(err => err.message).join(', ');

const onCompleted = (toggleModal, showToast) => data => {
  toggleModal();
  const { errors } = data.deleteOvalPolicy;
  if (Array.isArray(errors) && errors.length > 0) {
    showToast({
      type: 'error',
      message: formatError(joinErrors(errors)),
    });
  } else {
    showToast({
      type: 'success',
      message: __('OVAL policy was successfully deleted.'),
    });
  }
};

const onError = showToast => error => {
  showToast({ type: 'error', message: formatError(error) });
};

export const prepareMutation = (history, toggleModal, showToast) => () => {
  const pagination = pageToVars(useCurrentPagination(history));

  const options = {
    refetchQueries: [{ query: policiesQuery, variables: pagination }],
    onCompleted: onCompleted(toggleModal, showToast),
    onError: onError(showToast),
  };

  return useMutation(deleteOvalPolicyMutation, options);
};

export const submitDelete = (mutation, id) => {
  mutation({ variables: { id } });
};
