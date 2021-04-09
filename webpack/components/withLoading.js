import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';

import Loading from 'foremanReact/components/Loading';
import EmptyState from './EmptyState';

const errorStateTitle = __('Error!');
const emptyStateBody = '';

const withLoading = Component => {
  const Subcomponent = ({
    fetchFn,
    queryName,
    renameData,
    emptyStateTitle,
    ...rest
  }) => {
    const { loading, error, data } = fetchFn(rest);

    if (loading) {
      return <Loading />;
    }

    if (error) {
      return (
        <EmptyState
          error={error}
          title={errorStateTitle}
          body={error.message}
        />
      );
    }

    if (data[queryName].nodes.length === 0) {
      return <EmptyState title={emptyStateTitle} body={emptyStateBody} />;
    }

    return <Component {...rest} {...renameData(data)} />;
  };

  Subcomponent.propTypes = {
    fetchFn: PropTypes.func.isRequired,
    queryName: PropTypes.string.isRequired,
    renameData: PropTypes.func,
    emptyStateTitle: PropTypes.string.isRequired,
  };

  Subcomponent.defaultProps = {
    renameData: data => data,
  };

  return Subcomponent;
};

export default withLoading;
