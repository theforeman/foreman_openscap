import { useMutation } from '@apollo/client';
import { translate as __, sprintf } from 'foremanReact/common/I18n';

import { useCurrentPagination, pageToVars } from './pageParamsHelper';

const formatError = (error, name) =>
  sprintf(__('There was a following error when deleting %(name)s: %(error)s'), {
    name,
    error,
  });

const joinErrors = errors => errors.map(err => err.message).join(', ');

const onError = (showToast, resourceName) => error => {
  showToast({ type: 'error', message: formatError(error, resourceName) });
};

const onCompleted = (
  toggleModal,
  showToast,
  mutationName,
  successMsg,
  resourceName
) => data => {
  toggleModal();
  const { errors } = data[mutationName];
  if (Array.isArray(errors) && errors.length > 0) {
    showToast({
      type: 'error',
      message: formatError(joinErrors(errors), resourceName),
    });
  } else {
    showToast({
      type: 'success',
      message: successMsg,
    });
  }
};

export const prepareMutation = (
  history,
  showToast,
  refetchQuery,
  mutationName,
  successMsg,
  mutation,
  resourceName
) => toggleModal => {
  const pagination = pageToVars(useCurrentPagination(history));

  const options = {
    refetchQueries: [{ query: refetchQuery, variables: pagination }],
    onCompleted: onCompleted(
      toggleModal,
      showToast,
      mutationName,
      successMsg,
      resourceName
    ),
    onError: onError(showToast, resourceName),
  };

  return useMutation(mutation, options);
};

export const submitDelete = (mutation, id) => {
  mutation({ variables: { id } });
};
