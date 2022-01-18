import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';

import withLoading from '../../../components/withLoading';
import IndexTable from '../../../components/IndexTable';

const CvesTable = props => {
  const columns = [{ title: __('Name') }];

  const rows = props.hostgroups.map(hostgroup => ({
    cells: [{ title: hostgroup.name }],
    hostgroup,
  }));

  const actions = [];

  return (
    <IndexTable
      columns={columns}
      rows={rows}
      actions={actions}
      totalCount={props.totalCount}
      history={props.history}
      ariaTableLabel={__('Table of hostgroups for OVAL policy')}
    />
  );
};

CvesTable.propTypes = {
  hostgroups: PropTypes.array.isRequired,
  totalCount: PropTypes.number.isRequired,
  history: PropTypes.object.isRequired,
};

export default withLoading(CvesTable);
