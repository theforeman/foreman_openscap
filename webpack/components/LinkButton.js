import React from 'react';
import { Link } from 'react-router-dom';
import { Button } from '@patternfly/react-core';
import PropTypes from 'prop-types';

const LinkButton = ({
  path,
  btnVariant,
  btnText,
  isDisabled,
  btnAriaLabel,
  ouiaId,
}) => (
  <Link to={path}>
    <Button
      ouiaId={ouiaId}
      variant={btnVariant}
      isDisabled={isDisabled}
      aria-label={btnAriaLabel}
    >
      {btnText}
    </Button>
  </Link>
);

LinkButton.propTypes = {
  path: PropTypes.string.isRequired,
  btnText: PropTypes.string.isRequired,
  btnVariant: PropTypes.string,
  isDisabled: PropTypes.bool,
  btnAriaLabel: PropTypes.string,
  ouiaId: PropTypes.string,
};

LinkButton.defaultProps = {
  btnVariant: 'primary',
  isDisabled: false,
  btnAriaLabel: null,
  ouiaId: 'oscap-link-button',
};

export default LinkButton;
