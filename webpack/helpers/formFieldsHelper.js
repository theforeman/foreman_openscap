import React from 'react';
import PropTypes from 'prop-types';

import {
  FormGroup,
  TextInput,
  TextArea,
  FormSelect,
  FormSelectOption,
} from '@patternfly/react-core';
import { ExclamationCircleIcon } from '@patternfly/react-icons';

const wrapFieldProps = fieldProps => {
  const { onChange } = fieldProps;
  // modify onChange args to correctly wire formik with pf4 input handlers
  const wrappedOnChange = (value, event) => {
    onChange(event);
  };

  return { ...fieldProps, onChange: wrappedOnChange };
};

const shouldValidate = (form, fieldName) => {
  if (form.touched[fieldName]) {
    return form.errors[fieldName] ? 'error' : 'success';
  }

  return 'noval';
};

export const SelectField = props => {
  const { selectItems, field, form } = props;
  const fieldProps = wrapFieldProps(field);

  const valid = shouldValidate(form, field.name);

  return (
    <FormGroup
      label={props.label}
      isRequired={props.isRequired}
      helperTextInvalid={form.errors[field.name]}
      helperTextInvalidIcon={<ExclamationCircleIcon />}
      validated={valid}
    >
      <FormSelect
        {...fieldProps}
        className="without_select2"
        aria-label={fieldProps.name}
        validated={valid}
        isDisabled={form.isSubmitting}
      >
        {props.blankLabel !== null && (
          <FormSelectOption key={0} value="" label={props.blankLabel} />
        )}
        {selectItems.map((item, idx) => (
          <FormSelectOption key={idx + 1} value={item.id} label={item.name} />
        ))}
      </FormSelect>
    </FormGroup>
  );
};

SelectField.propTypes = {
  selectItems: PropTypes.array,
  label: PropTypes.string.isRequired,
  isRequired: PropTypes.bool,
  field: PropTypes.object.isRequired,
  form: PropTypes.object.isRequired,
  blankLabel: PropTypes.string,
};
SelectField.defaultProps = {
  selectItems: [],
  isRequired: false,
  blankLabel: '',
};

const fieldWithHandlers = Component => {
  const Subcomponent = ({ label, form, field, isRequired, ...rest }) => {
    const fieldProps = wrapFieldProps(field);
    const valid = shouldValidate(form, field.name);

    return (
      <FormGroup
        label={label}
        isRequired={isRequired}
        helperTextInvalid={form.errors[field.name]}
        helperTextInvalidIcon={<ExclamationCircleIcon />}
        validated={valid}
      >
        <Component
          aria-label={fieldProps.name}
          {...fieldProps}
          {...rest}
          validated={valid}
          isDisabled={form.isSubmitting}
        />
      </FormGroup>
    );
  };

  Subcomponent.propTypes = {
    form: PropTypes.object.isRequired,
    field: PropTypes.object.isRequired,
    label: PropTypes.string.isRequired,
    isRequired: PropTypes.bool,
  };

  Subcomponent.defaultProps = {
    isRequired: false,
  };

  return Subcomponent;
};

export const TextField = fieldWithHandlers(TextInput);
export const TextAreaField = fieldWithHandlers(TextArea);
