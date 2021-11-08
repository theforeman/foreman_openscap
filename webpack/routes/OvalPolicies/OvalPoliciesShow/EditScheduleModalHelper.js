import { translate as __, sprintf } from 'foremanReact/common/I18n';
import { policyToAttrs, onUpdateError } from './OvalPoliciesShowHelper';
import { joinErrors } from '../../../helpers/mutationHelper';

const formatError = error =>
  sprintf(__('There was a following error when updating policy: %(error)s'), {
    error,
  });

const onSuccess = (showToast, setSubmitting, closeModal, policy) => result => {
  const { errors } = result.data.updateOvalPolicy;
  setSubmitting(false);
  if (Array.isArray(errors) && errors.length > 0) {
    showToast({
      type: 'error',
      message: formatError(joinErrors(errors)),
    });
  } else {
    closeModal();
    showToast({
      type: 'success',
      message: __('OVAL policy was successfully updated.'),
    });
  }
};

export const onSubmit = (callMutation, showToast, closeModal, policy) => (
  values,
  actions
) => {
  const periodMapping = {
    weekly: 'weekday',
    monthly: 'dayOfMonth',
    custom: 'cronLine',
  };

  const variables = {
    ...policyToAttrs(values, ['period', periodMapping[values.period]]),
    id: policy.id,
  };
  callMutation({ variables })
    // eslint-disable-next-line promise/prefer-await-to-then
    .then(onSuccess(showToast, actions.setSubmitting, closeModal, policy))
    .catch(onUpdateError(showToast, () => actions.setSubmitting(false)));
};

export const initializeValues = policy => {
  const initialValues = policyToAttrs(policy, [
    'period',
    'weekday',
    'dayOfMonth',
    'cronLine',
  ]);

  return Object.entries(initialValues).reduce((memo, [key, value]) => {
    if (value !== null) {
      memo[key] = value;
    } else {
      memo[key] = '';
    }
    return memo;
  }, {});
};
