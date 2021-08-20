import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { Formik, Field as FormikField } from 'formik';
import { useMutation } from '@apollo/client';
import { translate as __ } from 'foremanReact/common/I18n';
import { Button, Form as PfForm, ActionGroup } from '@patternfly/react-core';

import createOvalPolicy from '../../../graphql/mutations/createOvalPolicy.gql';

import {
  TextField,
  TextAreaField,
  SelectField,
} from '../../../helpers/formFieldsHelper';
import HostgroupSelect from './HostgroupSelect';
import withLoading from '../../../components/withLoading';

import { ovalPoliciesPath } from '../../../helpers/pathsHelper';
import LinkButton from '../../../components/LinkButton';

import {
  createValidationSchema,
  onSubmit,
  initialValues,
} from './NewOvalPolicyFormHelpers';

const NewOvalPolicyForm = ({ history, showToast, ovalContents }) => {
  const [callMutation] = useMutation(createOvalPolicy);

  const [assignedHgs, setAssignedHgs] = useState([]);
  const [hgsShowError, setHgsShowError] = useState(false);
  const [hgsError, setHgsError] = useState('');

  const onHgsError = error => {
    setHgsShowError(true);
    setHgsError(error);
  };

  return (
    <Formik
      onSubmit={onSubmit(
        history,
        showToast,
        callMutation,
        assignedHgs,
        onHgsError
      )}
      initialValues={initialValues}
      validationSchema={createValidationSchema()}
    >
      {formProps => (
        <PfForm>
          <FormikField
            name="name"
            component={TextField}
            label={__('Name')}
            isRequired
          />
          <FormikField
            name="description"
            component={TextAreaField}
            label={__('Description')}
          />
          <FormikField
            name="cronLine"
            component={TextField}
            label={__('Schedule')}
            isRequired
          />
          <FormikField
            name="ovalContentId"
            component={SelectField}
            selectItems={ovalContents}
            label={__('OVAL Content')}
            isRequired
            blankLabel={__('Choose OVAL Content')}
          />
          <HostgroupSelect
            selected={assignedHgs}
            setSelected={setAssignedHgs}
            showError={hgsShowError}
            setShowError={setHgsShowError}
            hgsError={hgsError}
            isDisabled={formProps.isSubmitting}
          />
          <ActionGroup>
            <Button
              variant="primary"
              onClick={formProps.handleSubmit}
              isDisabled={
                !formProps.isValid ||
                formProps.isSubmitting ||
                (hgsShowError && hgsError)
              }
              aria-label="submit"
            >
              {__('Submit')}
            </Button>
            <LinkButton
              path={ovalPoliciesPath}
              btnVariant="link"
              btnText={__('Cancel')}
              btnAriaLabel="cancel"
              isDisabled={formProps.isSubmitting}
            />
          </ActionGroup>
        </PfForm>
      )}
    </Formik>
  );
};

NewOvalPolicyForm.propTypes = {
  history: PropTypes.object.isRequired,
  showToast: PropTypes.func.isRequired,
  ovalContents: PropTypes.array.isRequired,
};

export default withLoading(NewOvalPolicyForm);
