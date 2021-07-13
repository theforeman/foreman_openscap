import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  Button,
  Split,
  SplitItem,
  Spinner,
  FormGroup,
} from '@patternfly/react-core';
import {
  TimesIcon,
  CheckIcon,
  PencilAltIcon,
  ExclamationCircleIcon,
} from '@patternfly/react-icons';

import './EditableInput.scss';

const EditableInput = props => {
  const [editing, setEditing] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const [inputValue, setInputValue] = useState(props.value);
  const [error, setError] = useState('');
  const [touched, setTouched] = useState(false);

  const stopSubmitting = () => setSubmitting(false);

  const handleSubmit = event => {
    event.preventDefault();
    onSubmit();
  };

  const onFinish = () => {
    setSubmitting(false);
    setEditing(false);
  };

  const onSubmit = () => {
    setSubmitting(true);
    props.onConfirm(inputValue, onFinish, stopSubmitting, onError);
  };

  const onError = err => {
    setTouched(false);
    setError(err);
  };

  const onCancel = () => {
    setInputValue(props.value);
    setEditing(false);
  };

  const onChange = value => {
    if (!touched) {
      setTouched(true);
    }
    setInputValue(value);
  };

  const editBtn = (
    <SplitItem>
      <Button
        className="inline-edit-icon"
        aria-label={`edit ${props.attrName}`}
        variant="plain"
        onClick={() => setEditing(true)}
      >
        <PencilAltIcon />
      </Button>
    </SplitItem>
  );

  if (!editing) {
    return (
      <Split>
        <SplitItem>{props.value || <i>{__('None provided')}</i>}</SplitItem>
        {props.allowed && editBtn}
      </Split>
    );
  }

  const Component = props.component;

  const shouldValidate = (isTouched, err) => {
    if (!isTouched) {
      return err ? 'error' : 'success';
    }
    return 'noval';
  };

  const valid = shouldValidate(touched, error);

  return (
    <Split>
      <SplitItem>
        <form onSubmit={handleSubmit} className="pf-c-form">
          <FormGroup
            helperTextInvalid={error}
            helperTextInvalidIcon={<ExclamationCircleIcon />}
            validated={valid}
          >
            <Component
              {...props.inputProps}
              type="text"
              aria-label={`${props.attrName} text input`}
              isDisabled={submitting}
              value={inputValue || ''}
              onChange={onChange}
              validated={valid}
            />
          </FormGroup>
        </form>
      </SplitItem>
      <SplitItem>
        <Button
          aria-label={`submit ${props.attrName}`}
          variant="plain"
          onClick={onSubmit}
          isDisabled={submitting}
        >
          <CheckIcon />
        </Button>
      </SplitItem>
      <SplitItem>
        <Button
          aria-label={`cancel editing ${props.attrName}`}
          variant="plain"
          onClick={onCancel}
          isDisabled={submitting}
        >
          <TimesIcon />
        </Button>
      </SplitItem>
      <SplitItem>
        {submitting && (
          <Spinner
            key="spinner"
            size="lg"
            id={`edit-${props.attrName}-spinner`}
          />
        )}
      </SplitItem>
    </Split>
  );
};

EditableInput.propTypes = {
  allowed: PropTypes.bool.isRequired,
  value: PropTypes.string,
  onConfirm: PropTypes.func.isRequired,
  attrName: PropTypes.string.isRequired,
  component: PropTypes.object.isRequired,
  inputProps: PropTypes.object,
};

EditableInput.defaultProps = {
  inputProps: {},
  value: '',
};

export default EditableInput;
