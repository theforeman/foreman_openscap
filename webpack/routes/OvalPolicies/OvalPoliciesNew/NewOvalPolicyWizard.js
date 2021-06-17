import React, { useState } from 'react';
import { Formik } from 'formik';
import { useQuery, useMutation } from '@apollo/client';

import { Button, Wizard, Form as PfForm } from '@patternfly/react-core';

import EmptyState from '../../../components/EmptyState';
import Loading from 'foremanReact/components/Loading';

import ovalContentsQuery from '../../../graphql/queries/ovalContents.gql';
import ovalPoliciesQuery from '../../../graphql/queries/ovalPolicies.gql';
import createOvalPolicy from '../../../graphql/mutations/createOvalPolicy.gql';

import { ovalPoliciesPath } from '../../../helpers/pathsHelper';

import { createValidationSchema, stepsFactory, onSubmit, initialValues } from './NewOvalPolicyWizardHelpers';

const NewOvalPolicyWizard = props => {
  const [callMutation] = useMutation(createOvalPolicy);

  const [assignedHgs, setAssignedHgs] = useState([]);
  const [stepReached, setStepReached] = useState(0);

  const onNextStep = ({ id }) => {
    if (stepReached < id) {
      setStepReached(id);
    }
  }

  const onHgAssignChange = allHgs => (event, isSelected, rowId, rowAttrs) => {
    let newAssignedHgs;
    if (rowId === -1) {
      newAssignedHgs = isSelected ? allHgs.map(hg => hg.id) : [];
    } else {
      let id = rowAttrs.hostgroup.id;
      newAssignedHgs = isSelected ? [...assignedHgs, id] : assignedHgs.filter(item => item !== id);
    }
    setAssignedHgs(newAssignedHgs);
  }

  // should we merge queries somehow to improve error handling?
  const policiesData = useQuery(ovalPoliciesQuery);
  const ovalContentsData = useQuery(ovalContentsQuery);

  if (ovalContentsData.loading || policiesData.loading) {
    return <Loading />
  }

  const loadError = ovalContentsData.error || policiesData.error

  if (loadError) {
    return <EmptyState error={loadError} title={'Error!'} body={loadError.message} />
  }

  const ovalPolicies = policiesData.data.ovalPolicies.nodes;
  const ovalContents = ovalContentsData.data.ovalContents.nodes;

  return (
    <Formik
      onSubmit={onSubmit(props.history, props.showToast, callMutation, assignedHgs)}
      initialValues={initialValues}
      validationSchema={createValidationSchema(ovalPolicies)}
    >
      {formProps => {

        const steps = stepsFactory(
          props,
          { enableNext: formProps.isValid,
            isSubmitting: formProps.isSubmitting,
            onHgAssignChange,
            assignedHgs,
            ovalContents,
            ovalPolicies,
            stepReached })

        return (
          <Wizard
            steps={steps}
            onNext={onNextStep}
            onClose={() => props.history.push(ovalPoliciesPath)}
            onSave={formProps.handleSubmit}
          />
        )
      }}
    </Formik>
  );
}

export default NewOvalPolicyWizard;
