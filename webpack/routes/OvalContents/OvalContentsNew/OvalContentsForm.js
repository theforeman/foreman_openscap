import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { Formik, Field as FormikField } from 'formik';

import {
  Form as PfForm,
  ActionGroup,
  Button,
  FileUpload,
  FormGroup,
  Radio,
  Spinner,
} from '@patternfly/react-core';
import {
  onSubmit,
  createValidationSchema,
  validateFile,
  submitDisabled,
} from './OvalContentsNewHelper';
import { ovalContentsPath } from '../../../helpers/pathsHelper';

import IndexLayout from '../../../components/IndexLayout';
import { TextField } from '../../../helpers/formFieldsHelper';

import withLoading from '../../../components/withLoading';

const OvalContentsNew = props => {
  const [file, setFile] = useState(null);
  const [fileTouched, setFileTouched] = useState(false);
  const [fileFromUrl, setFileFromUrl] = useState(true);

  const handleFileChange = (value, filename, event) => {
    setFile(value);
    setFileTouched(true);
  };

  return (
    <IndexLayout pageTitle={__('New OVAL Content')} contentWidthSpan={6}>
      <Formik
        onSubmit={(values, actions) =>
          onSubmit(
            values,
            actions,
            props.showToast,
            props.history,
            fileFromUrl,
            file
          )
        }
        initialValues={{ name: '', url: '' }}
        validationSchema={createValidationSchema(fileFromUrl)}
      >
        {formProps => (
          <PfForm>
            <FormikField
              label="Name"
              name="name"
              component={TextField}
              isRequired
            />
            <FormGroup label={__('OVAL Content Source')}>
              <Radio
                id="scap-file-source-url"
                isChecked={fileFromUrl}
                isDisabled={formProps.isSubmitting}
                name="fileSource"
                onChange={() => {
                  setFileFromUrl(true);
                  // Force validations to run by setting the same value.
                  // Workaround for https://github.com/formium/formik/issues/1755
                  formProps.setFieldValue(formProps.values.url);
                }}
                label={__('OVAL Content from URL')}
              />
              <Radio
                id="scap-file-source-file"
                isChecked={!fileFromUrl}
                isDisabled={formProps.isSubmitting}
                name="fileSource"
                onChange={() => {
                  setFileFromUrl(false);
                  const filtered = Object.entries(formProps.errors).filter(
                    ([key, value]) => key !== 'url'
                  );
                  formProps.setErrors(Object.fromEntries(filtered));
                }}
                label={__('OVAL Content from file')}
              />
            </FormGroup>
            {!fileFromUrl ? (
              <FormGroup label="File" isRequired>
                <FileUpload
                  value={file}
                  filename={file ? file.name : ''}
                  onChange={handleFileChange}
                  isDisabled={formProps.isSubmitting}
                  validated={validateFile(file, fileTouched)}
                />
              </FormGroup>
            ) : (
              <FormikField
                label={__('URL')}
                name="url"
                component={TextField}
                isRequired
              />
            )}
            <ActionGroup>
              <Button
                variant="primary"
                onClick={formProps.handleSubmit}
                isDisabled={submitDisabled(formProps, file, fileFromUrl)}
              >
                {__('Submit')}
              </Button>
              <Button
                variant="link"
                isDisabled={formProps.isSubmitting}
                onClick={() => props.history.push(ovalContentsPath)}
              >
                {__('Cancel')}
              </Button>
              {formProps.isSubmitting ? <Spinner size="lg" /> : null}
            </ActionGroup>
          </PfForm>
        )}
      </Formik>
    </IndexLayout>
  );
};

OvalContentsNew.propTypes = {
  showToast: PropTypes.func.isRequired,
  history: PropTypes.object.isRequired,
};

export default withLoading(OvalContentsNew);
