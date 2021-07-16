import { useMutation } from '@apollo/client';
import { translate as __, sprintf } from 'foremanReact/common/I18n';
import syncOvalContent from '../../../graphql/mutations/syncOvalContent.gql';

const formatError = error =>
  sprintf(
    __('There was a following error when syncing OVAL content: %s'),
    error
  );

const joinErrors = errors => errors.map(err => err.message).join(', ');

const onError = showToast => error => {
  showToast({ type: 'error', message: formatError(error) });
};

const onCompleted = (toggleModal, showToast) => data => {
  toggleModal();
  const { errors } = data.syncOvalContent;
  if (Array.isArray(errors) && errors.length > 0) {
    showToast({
      type: 'error',
      message: formatError(joinErrors(errors)),
    });
  } else {
    showToast({
      type: 'success',
      message: __('OVAL content was successfully synced.'),
    });
  }
};

export const prepareMutation = (showToast, closeModal) => () => {
  const options = {
    onCompleted: onCompleted(closeModal, showToast),
    onError: onError(showToast),
  };
  return useMutation(syncOvalContent, options);
};
