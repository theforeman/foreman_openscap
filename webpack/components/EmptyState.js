import React from 'react';
import {
  EmptyState as PfEmptyState,
  EmptyStateBody,
  EmptyStateIcon as PfEmptyStateIcon,
  EmptyStateVariant,
  Bullseye,
  Title,
} from '@patternfly/react-core';
import PropTypes from 'prop-types';
import {
  CubeIcon,
  ExclamationCircleIcon,
  SearchIcon,
} from '@patternfly/react-icons';
import { global_danger_color_200 as dangerColor } from '@patternfly/react-tokens';

const EmptyStateIcon = ({ error, search }) => {
  if (error)
    return (
      <PfEmptyStateIcon
        icon={ExclamationCircleIcon}
        color={dangerColor.value}
      />
    );
  if (search) return <PfEmptyStateIcon icon={SearchIcon} />;
  return <PfEmptyStateIcon icon={CubeIcon} />;
};

const EmptyState = ({ title, body, error, search }) => (
  <Bullseye>
    <PfEmptyState variant={EmptyStateVariant.small}>
      <EmptyStateIcon error={!!error} search={search} />
      <Title headingLevel="h2" size="lg">
        {title}
      </Title>
      <EmptyStateBody>{body}</EmptyStateBody>
    </PfEmptyState>
  </Bullseye>
);

EmptyStateIcon.propTypes = {
  error: PropTypes.bool,
  search: PropTypes.bool,
};

EmptyStateIcon.defaultProps = {
  error: false,
  search: false,
};

EmptyState.propTypes = {
  title: PropTypes.string,
  body: PropTypes.string,
  error: PropTypes.oneOfType([PropTypes.shape({}), PropTypes.string]),
  search: PropTypes.bool,
};

EmptyState.defaultProps = {
  title: 'Unable to fetch data from server',
  body:
    'There was an error retrieving data from the server. Check your connection and try again.',
  error: undefined,
  search: false,
};

export default EmptyState;
