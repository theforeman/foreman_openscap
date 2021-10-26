import React from 'react';
import { Link } from 'react-router-dom';
import { Button } from '@patternfly/react-core';
import PropTypes from 'prop-types';

const LinkButton = ({ path, btnVariant, btnText, isDisabled }) => (
  <Link to={path}>
    <Button variant={btnVariant} isDisabled={isDisabled}>
      {btnText}
    </Button>
  </Link>
);

LinkButton.propTypes = {
  path: PropTypes.string.isRequired,
  btnText: PropTypes.string.isRequired,
  btnVariant: PropTypes.string,
  isDisabled: PropTypes.bool,
};

LinkButton.defaultProps = {
  btnVariant: 'primary',
  isDisabled: false,
};

export default LinkButton;
