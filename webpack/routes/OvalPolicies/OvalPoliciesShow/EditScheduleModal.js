import React from 'react';
import { Formik } from 'formik';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';

import {
  Button,
  Form as PfForm,
  Spinner,
  Modal,
  ModalVariant,
} from '@patternfly/react-core';
import ScheduleFields from '../../../components/ScheduleFields';
import { onSubmit, initializeValues } from './EditScheduleModalHelper';

const EditScheduleModal = ({
  callMutation,
  onClose,
  showToast,
  policy,
  isOpen,
}) => (
  <Formik
    onSubmit={onSubmit(callMutation, showToast, onClose, policy)}
    initialValues={initializeValues(policy)}
  >
    {formProps => {
      const actions = [
        <Button
          aria-label="submit"
          key="confirm"
          variant="primary"
          onClick={formProps.handleSubmit}
          isDisabled={formProps.isSubmitting || !formProps.isValid}
        >
          {__('Submit')}
        </Button>,
        <Button
          aria-label="cancel"
          key="cancel"
          variant="link"
          onClick={onClose}
          isDisabled={formProps.isSubmitting}
        >
          {__('Cancel')}
        </Button>,
      ];

      if (formProps.isSubmitting) {
        actions.push(
          <Spinner key="spinner" size="lg" id="edit-schedule-spinner" />
        );
      }

      return (
        <Modal
          variant={ModalVariant.large}
          title={__('OVAL Policy Schedule')}
          isOpen={isOpen}
          className="foreman-modal modal-high"
          showClose={false}
          actions={actions}
          disableFocusTrap
        >
          <PfForm>
            <ScheduleFields
              period={formProps.values.period}
              addBlanks={false}
            />
          </PfForm>
        </Modal>
      );
    }}
  </Formik>
);

EditScheduleModal.propTypes = {
  callMutation: PropTypes.func.isRequired,
  onClose: PropTypes.func.isRequired,
  showToast: PropTypes.func.isRequired,
  policy: PropTypes.object.isRequired,
  isOpen: PropTypes.bool.isRequired,
};

export default EditScheduleModal;
