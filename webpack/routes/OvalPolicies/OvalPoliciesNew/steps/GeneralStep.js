import React from 'react'
import { Field as FormikField } from 'formik';

import { Form as PfForm } from '@patternfly/react-core';
import { TextField, TextAreaField, SelectField } from '../../../../helpers/formFieldsHelper';

const GeneralStep = props => {
  const nameProps = {
    label: "Name",
    isRequired: true,
  }

  const scheduleProps = {
    label: "Schedule",
    isRequired: true
  }

  const ovalContentProps = {
    label: "OVAL Content",
    isRequired: true
  }

  return (
    <React.Fragment>
      <PfForm>
        <FormikField name="name" component={TextField} {...nameProps} />
        <FormikField name="description" component={TextAreaField} label="Description" />
        <FormikField name="cronLine" component={TextField} {...scheduleProps} />
        <FormikField name="ovalContentId" component={SelectField} selectItems={props.ovalContents} {...ovalContentProps} blankLabel={"Choose OVAL Content"}/>
      </PfForm>
    </React.Fragment>
  )
}

export default GeneralStep;
