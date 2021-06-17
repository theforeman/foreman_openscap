import React from 'react';
import * as Yup from 'yup';

import { ovalPoliciesPath } from '../../../helpers/pathsHelper';

import GeneralStep from './steps/GeneralStep';
import HostgroupsStep from './steps/HostgroupsStep';

const pluckNames = (models) => models

export const createValidationSchema = (existingPolicies) => {
  const existingNames = existingPolicies.map(model => model.name);

  return Yup.object().shape({
    name: Yup.string().required("can't be blank").test('is-unique', 'has already been taken', value => value && !existingNames.includes(value)),
    ovalContentId: Yup.string().required("can't be blank"),
    cronLine: Yup.string().test('is-cron', 'is not a valid cronline', value => value && value.trim().split(' ').length === 5)
  });
}

export const stepsFactory = (props, additional) => {
  const steps = [
    {
      id: 0,
      name: 'General',
      component: <GeneralStep {...props} ovalContents={additional.ovalContents} />,
      enableNext: additional.enableNext && !additional.isSubmitting
    },
    {
      id: 1,
      name: 'Hostgroups',
      component: <HostgroupsStep {...props} onHgAssignChange={additional.onHgAssignChange} assignedHgs={additional.assignedHgs} />,
      enableNext: additional.enableNext && !additional.isSubmitting,
      nextButtonText: 'Submit',
      canJumpTo: additional.stepReached >= 1
    }
  ]

  return steps
}

const prepareErrors = errors => {
  return errors.reduce((memo, item) => {
    let key = item.path[item.path.length - 1];
    memo[key] = item.message;
    return memo;
  }, {})
}

export const onSubmit = (history, showToast, callMutation, assignedHgs) => (values, actions) => {
  const onCompleted = (response) => {
    const errors = response.data.createOvalPolicy.errors;
    if (errors.length === 0) {
      history.push(ovalPoliciesPath);
      showToast({ type: 'success', message: 'OVAL Policy succesfully created.' });
    } else {
      actions.setSubmitting(false);
      actions.setErrors(prepareErrors(errors));
    }
  }

  const onError = (error) => {
    showToast({ type: 'error', message: `Failed to create OVAL Policy: ${error}` });
    actions.setSubmitting(false);
  }

  callMutation({ variables: { ...values, period: 'custom', hostgroupIds: assignedHgs } }).then(onCompleted, onError);
}

export const initialValues = {
  name: "",
  description: "",
  ovalContentId: "",
  cronLine: ""
}