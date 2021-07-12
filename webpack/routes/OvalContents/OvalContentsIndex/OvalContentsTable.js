import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';

import withLoading from '../../../components/withLoading';
import withDeleteModal from '../../../components/withDeleteModal';
import IndexTable from '../../../components/IndexTable';

const OvalContentsTable = props => {
  const columns = [{ title: __('Name') }];

  const rows = props.ovalContents.map(ovalContent => ({
    cells: [{ title: ovalContent.name }],
    ovalContent,
  }));

  const actionResolver = (rowData, rest) => {
    const actions = [];
    if (rowData.ovalContent.meta.canDestroy) {
      actions.push({
        title: __('Delete OVAL Content'),
        onClick: (event, rowId, rData, extra) => {
          props.toggleModal(rData.ovalContent);
        },
      });
    }
    return actions;
  };

  return (
    <IndexTable
      columns={columns}
      rows={rows}
      actionResolver={actionResolver}
      pagination={props.pagination}
      totalCount={props.totalCount}
      history={props.history}
      ariaTableLabel={__('OVAL Contents table')}
    />
  );
};

OvalContentsTable.propTypes = {
  ovalContents: PropTypes.array.isRequired,
  pagination: PropTypes.object.isRequired,
  totalCount: PropTypes.number.isRequired,
  history: PropTypes.object.isRequired,
  toggleModal: PropTypes.func.isRequired,
};

export default withLoading(withDeleteModal(OvalContentsTable));
