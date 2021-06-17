import React from 'react';
import PropTypes from 'prop-types';
import { Button } from '@patternfly/react-core';

import { translate as __ } from 'foremanReact/common/I18n';

import IndexTable from '../../../components/IndexTable';
import withLoading from '../../../components/withLoading';

import { linkCell } from '../../../helpers/tableHelper';
import { ovalPoliciesPath, modelPath, ovalPoliciesNewPath } from '../../../helpers/pathsHelper';

const OvalPoliciesTable = props => {
  const columns = [{ title: __('Name') }, { title: __('OVAL Content') }];

  const rows = props.policies.map(policy => ({
    cells: [
      { title: linkCell(modelPath(ovalPoliciesPath, policy), policy.name) },
      { title: policy.ovalContent.name },
    ],
    policy,
  }));

  const actions = [];

  const createBtn = (
    <Button onClick={() => props.history.push(ovalPoliciesNewPath)} variant="primary" aria-label="create_oval_policy">
      {__('Create OVAL Policy')}
    </Button>
  )

  return (
    <IndexTable
      columns={columns}
      rows={rows}
      actions={actions}
      pagination={props.pagination}
      totalCount={props.totalCount}
      history={props.history}
      ariaTableLabel={__('OVAL Policies Table')}
      toolbarBtns={createBtn}
    />
  );
};

OvalPoliciesTable.propTypes = {
  policies: PropTypes.array.isRequired,
  pagination: PropTypes.object.isRequired,
  totalCount: PropTypes.number.isRequired,
  history: PropTypes.object.isRequired,
};

export default withLoading(OvalPoliciesTable);
