import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { translate as __, sprintf } from 'foremanReact/common/I18n';
import ConfirmModal from './ConfirmModal';

const withDelete = Component => {
  const Subcomponent = ({
    confirmDeleteTitle,
    submitDelete,
    prepareMutation,
    ...rest
  }) => {
    const [toDelete, setToDelete] = useState(null);

    const toggleModal = (item = null) => {
      setToDelete(item);
    };

    return (
      <React.Fragment>
        <Component {...rest} toggleModal={toggleModal} />
        <ConfirmModal
          title={confirmDeleteTitle}
          text={
            toDelete
              ? sprintf(
                  __('Are you sure you want to delete %s?'),
                  toDelete.name
                )
              : ''
          }
          onClose={toggleModal}
          isOpen={!!toDelete}
          onConfirm={submitDelete}
          prepareMutation={() => prepareMutation(toggleModal)}
          record={toDelete}
        />
      </React.Fragment>
    );
  };

  Subcomponent.propTypes = {
    confirmDeleteTitle: PropTypes.string.isRequired,
    submitDelete: PropTypes.func.isRequired,
    prepareMutation: PropTypes.func.isRequired,
  };

  return Subcomponent;
};

export default withDelete;
