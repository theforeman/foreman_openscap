import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { Button } from '@patternfly/react-core';

import withLoading from '../../../components/withLoading';
import IndexTable from '../../../components/IndexTable';
import { ovalContentsNewPath } from '../../../helpers/pathsHelper';

const OvalContentsTable = props => {
  const columns = [{ title: __('Name') }];

  const rows = props.ovalContents.map(ovalContent => ({
    cells: [{ title: ovalContent.name }],
    ovalContent,
  }));

  const createBtn = (
    <Button
      onClick={() => props.history.push(ovalContentsNewPath)}
      variant="primary"
      aria-label="create_oval_content"
    >
      {__('Create OVAL Content')}
    </Button>
  );

  const actions = [];

  return (
    <IndexTable
      columns={columns}
      rows={rows}
      actions={actions}
      pagination={props.pagination}
      totalCount={props.totalCount}
      history={props.history}
      ariaTableLabel={__('OVAL Contents table')}
      toolbarBtns={createBtn}
    />
  );
};

OvalContentsTable.propTypes = {
  ovalContents: PropTypes.array.isRequired,
  pagination: PropTypes.object.isRequired,
  totalCount: PropTypes.number.isRequired,
  history: PropTypes.object.isRequired,
};

export default withLoading(OvalContentsTable);
