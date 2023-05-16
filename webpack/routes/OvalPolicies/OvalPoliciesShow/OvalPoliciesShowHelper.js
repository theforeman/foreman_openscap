import { translate as __, sprintf } from 'foremanReact/common/I18n';
import { decodeModelId } from '../../../helpers/globalIdHelper';
import { addSearch } from '../../../helpers/pageParamsHelper';
import { newJobPath } from '../../../helpers/pathsHelper';

export const policySchedule = policy => {
  switch (policy.period) {
    case 'weekly':
      return sprintf(__('Weekly, on %s'), policy.weekday);
    case 'monthly':
      return sprintf(__('Monthly, day of month: %s'), policy.dayOfMonth);
    case 'custom':
      return sprintf(__('Custom cron: %s'), policy.cronLine);
    default:
      return __('Unknown schedule');
  }
};

const targetingScopedSearchQuery = policy => {
  const hgIds = policy.hostgroups.nodes.reduce((memo, hg) => {
    const ids = [decodeModelId(hg)].concat(
      hg.descendants.nodes.map(decodeModelId)
    );
    return ids.reduce(
      (acc, id) => (acc.includes(id) ? acc : [...acc, id]),
      memo
    );
  }, []);

  if (hgIds.length === 0) {
    return '';
  }

  return `hostgroup_id ^ (${hgIds.join(' ')})`;
};

export const newJobFormPath = (policy, policyId) =>
  addSearch(newJobPath, {
    feature: 'foreman_openscap_run_oval_scans',
    host_ids: targetingScopedSearchQuery(policy),
    'inputs[oval_policies]': policyId,
  });

const policyToAttrs = (policy, attrs) =>
  Object.entries(policy).reduce((memo, [key, value]) => {
    if (attrs.includes(key)) {
      memo[key] = value;
    }
    return memo;
  }, {});

const onUpdateSuccess = (
  closeEditable,
  stopSubmitting,
  showToast,
  attr,
  onValidationError
) => result => {
  const { errors } = result.data.updateOvalPolicy;
  if (Array.isArray(errors) && errors.length > 0) {
    stopSubmitting();
    if (
      errors.length === 1 &&
      errors[0].path.join(' ') === `attributes ${attr}`
    ) {
      onValidationError(errors[0].message);
    } else {
      showToast({
        type: 'error',
        message: formatError(joinErrors(errors)),
      });
    }
  } else {
    closeEditable();
    showToast({
      type: 'success',
      message: __('OVAL policy was successfully updated.'),
    });
  }
};

const formatError = error =>
  sprintf(
    __('There was a following error when updating OVAL policy: %s'),
    error
  );

const joinErrors = errors => errors.map(err => err.message).join(', ');

const onUpdateError = (showToast, stopSubmitting) => error => {
  stopSubmitting();
  showToast({ type: 'error', message: formatError(error.message) });
};

export const onAttrUpdate = (attr, policy, callMutation, showToast) => (
  newValue,
  closeEditable,
  stopSubmitting,
  onValidationError
) => {
  const vars = policyToAttrs(policy, ['id', 'name', 'description', 'cronLine']);
  vars[attr] = newValue;
  return (
    callMutation({ variables: vars })
      // eslint-disable-next-line promise/prefer-await-to-then
      .then(
        onUpdateSuccess(
          closeEditable,
          stopSubmitting,
          showToast,
          attr,
          onValidationError
        )
      )
      .catch(onUpdateError(showToast, stopSubmitting))
  );
};
