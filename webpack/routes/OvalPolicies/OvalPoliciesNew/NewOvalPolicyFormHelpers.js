import * as Yup from 'yup';
import { translate as __ } from 'foremanReact/common/I18n';

import { ovalPoliciesPath } from '../../../helpers/pathsHelper';
import { decodeId, decodeModelId } from '../../../helpers/globalIdHelper';

export const createValidationSchema = () => {
  const cantBeBlank = __("can't be blank");

  return Yup.object().shape({
    name: Yup.string().required(cantBeBlank),
    ovalContentId: Yup.string().required(cantBeBlank),
    cronLine: Yup.string().test(
      'is-cron',
      __('is not a valid cronline'),
      value => value && value.trim().split(' ').length === 5
    ),
  });
};

const partitionById = (array, name) => {
  const res = array.reduce(
    (memo, item) => {
      if (item.id === name) {
        memo.left.push(item);
      } else {
        memo.right.push(item);
      }
      return memo;
    },
    { left: [], right: [] }
  );
  return [res.left, res.right];
};

const checksToMessage = checks =>
  checks.reduce((memo, check) => [...memo, check.failMsg], []).join(' ');

export const onSubmit = (
  history,
  showToast,
  callMutation,
  assignedHgs,
  setHgsError
) => (values, actions) => {
  const onCompleted = response => {
    const failedChecks = response.data.createOvalPolicy.checkCollection.filter(
      check => check.result === 'fail'
    );
    if (failedChecks.length === 0) {
      history.push(ovalPoliciesPath);
      showToast({
        type: 'success',
        message: 'OVAL Policy succesfully created.',
      });
    } else {
      actions.setSubmitting(false);

      const [validationChecks, withoutValidationChecks] = partitionById(
        failedChecks,
        'oval_policy_errors'
      );

      const [hgChecks, remainingChecks] = partitionById(
        withoutValidationChecks,
        'hostgroups_without_proxy'
      );
      if (validationChecks.length === 1) {
        actions.setErrors(validationChecks[0].errors);
      }
      if (hgChecks.length > 0) {
        setHgsError(checksToMessage(hgChecks));
      }
      if (remainingChecks.length > 0) {
        showToast({
          type: 'error',
          message: checksToMessage(remainingChecks),
        });
      }
    }
  };

  const onError = response => {
    showToast({
      type: 'error',
      message: `Failed to create OVAL Policy: ${response.error}`,
    });
    actions.setSubmitting(false);
  };

  const hostgroupIds = assignedHgs.map(decodeModelId);
  const variables = {
    ...values,
    ovalContentId: decodeId(values.ovalContentId),
    period: 'custom',
    hostgroupIds,
  };
  // eslint-disable-next-line promise/prefer-await-to-then
  callMutation({ variables }).then(onCompleted, onError);
};

export const initialValues = {
  name: '',
  description: '',
  ovalContentId: '',
  cronLine: '',
};
