import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { Button } from '@patternfly/react-core';

import withLoading from '../../../components/withLoading';
import withDeleteModal from '../../../components/withDeleteModal';
import IndexTable from '../../../components/IndexTable';
import {
  ovalContentsNewPath,
  ovalContentsPath,
  modelPath,
} from '../../../helpers/pathsHelper';

import { linkCell } from '../../../helpers/tableHelper';

const OvalContentsTable = props => {
  const columns = [
    { title: __('Name') },
    { title: __('URL') },
    { title: __('Original File Name') },
  ];

  const rows = props.ovalContents.map(ovalContent => ({
    cells: [
      {
        title: linkCell(
          modelPath(ovalContentsPath, ovalContent),
          ovalContent.name
        ),
      },
      { title: ovalContent.url || '' },
      { title: ovalContent.originalFilename || '' },
    ],
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

  const createBtn = (
    <Button
      onClick={() => props.history.push(ovalContentsNewPath)}
      variant="primary"
      aria-label="create_oval_content"
    >
      {__('Create OVAL Content')}
    </Button>
  );

  return (
    <IndexTable
      columns={columns}
      rows={rows}
      actionResolver={actionResolver}
      totalCount={props.totalCount}
      history={props.history}
      ariaTableLabel={__('OVAL Contents table')}
      toolbarBtns={createBtn}
    />
  );
};

OvalContentsTable.propTypes = {
  ovalContents: PropTypes.array.isRequired,
  totalCount: PropTypes.number.isRequired,
  history: PropTypes.object.isRequired,
  toggleModal: PropTypes.func.isRequired,
};

export default withLoading(withDeleteModal(OvalContentsTable));
