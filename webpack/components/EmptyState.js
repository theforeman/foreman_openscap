import React from 'react';
import {
  EmptyState as PfEmptyState,
  EmptyStateBody,
  EmptyStateFooter,
  EmptyStateVariant,
  Bullseye,
} from '@patternfly/react-core';
import PropTypes from 'prop-types';
import {
  CubeIcon,
  ExclamationCircleIcon,
  SearchIcon,
  LockIcon,
} from '@patternfly/react-icons';

const pickIcon = ({ error, search, lock }) => {
  if (error) return ExclamationCircleIcon;
  if (lock) return LockIcon;
  if (search) return SearchIcon;
  return CubeIcon;
};

const EmptyState = ({
  title,
  body,
  error,
  search,
  lock,
  primaryButton,
  ouiaEmptyStateTitleId,
}) => (
  <Bullseye>
    <PfEmptyState
      ouiaId={ouiaEmptyStateTitleId}
      variant={EmptyStateVariant.sm}
      headingLevel="h2"
      titleText={title}
      icon={pickIcon({ error: !!error, search, lock })}
      status={error ? 'danger' : undefined}
    >
      <EmptyStateBody>{body}</EmptyStateBody>
      {primaryButton && <EmptyStateFooter>{primaryButton}</EmptyStateFooter>}
    </PfEmptyState>
  </Bullseye>
);

EmptyState.propTypes = {
  title: PropTypes.string,
  body: PropTypes.oneOfType([PropTypes.string, PropTypes.node]),
  error: PropTypes.oneOfType([
    PropTypes.shape({}),
    PropTypes.string,
    PropTypes.bool,
  ]),
  search: PropTypes.bool,
  lock: PropTypes.bool,
  primaryButton: PropTypes.node,
  ouiaEmptyStateTitleId: PropTypes.string,
};

EmptyState.defaultProps = {
  title: 'Unable to fetch data from server',
  body:
    'There was an error retrieving data from the server. Check your connection and try again.',
  error: undefined,
  search: false,
  lock: false,
  primaryButton: null,
  ouiaEmptyStateTitleId: 'oscap-empty-state-title',
};

export default EmptyState;
