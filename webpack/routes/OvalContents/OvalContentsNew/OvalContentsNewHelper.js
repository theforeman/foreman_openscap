import * as Yup from 'yup';

import api from 'foremanReact/redux/API/API';
import { prepareErrors } from 'foremanReact/redux/actions/common/forms';
import { sprintf, translate as __ } from 'foremanReact/common/I18n';
import {
  ovalContentsPath,
  ovalContentsApiPath,
} from '../../../helpers/pathsHelper';

export const submitForm = (params, actions) => {
  const headers = {
    'Content-Type': 'multipart/form-data',
  };
  return api.post(ovalContentsApiPath, params, headers);
};

export const onSubmit = async (
  values,
  actions,
  showToast,
  history,
  fileFromUrl,
  file
) => {
  const formData = new FormData();
  if (fileFromUrl) {
    formData.append('oval_content[url]', values.url);
  } else {
    formData.append('oval_content[scap_file]', file);
  }
  formData.append('oval_content[name]', values.name);
  try {
    await submitForm(formData, actions);
    history.push(ovalContentsPath, { refreshOvalContents: true });
    showToast({
      type: 'success',
      message: sprintf(__('OVAL Content %s successfully created'), values.name),
    });
  } catch (error) {
    onError(error, actions, showToast);
  }
};

const onError = (error, actions, showToast) => {
  actions.setSubmitting(false);
  if (error.response?.status === 422) {
    actions.setErrors(prepareErrors(error?.response?.data?.error?.errors, {}));
  } else {
    showToast({
      type: 'error',
      message: __(
        'Unknown error when submitting data, please try again later.'
      ),
    });
  }
};

export const validateFile = (file, touched) => {
  if (!touched) {
    return 'default';
  }
  return file ? 'success' : 'error';
};

export const submitDisabled = (formProps, file, fileFromUrl) =>
  formProps.isSubmitting || !formProps.isValid || (!fileFromUrl && !file);

export const createValidationSchema = contentFromUrl =>
  Yup.object().shape({
    name: Yup.string().required("can't be blank"),
    ...(contentFromUrl && { url: Yup.string().required("can't be blank") }),
  });
