import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';

import { hostsPath } from '../../../helpers/pathsHelper';
import { decodeId } from '../../../helpers/globalIdHelper';

import withLoading from '../../../components/withLoading';
import IndexTable from '../../../components/IndexTable';

const CvesTable = props => {
  const columns = [
    { title: __('Ref Id') },
    { title: __('Has Errata?') },
    { title: __('Hosts Count') },
  ];

  const cveRefId = cve => (
    <a href={cve.refUrl} rel="noopener noreferrer" target="_blank">
      {cve.refId}
    </a>
  );

  const hostCount = cve =>
    props.linkCell(hostsPath, cve.hosts.nodes.length, {
      search: `cve_id = ${decodeId(cve)}`,
    });

  const rows = props.cves.map(cve => ({
    cells: [
      { title: cveRefId(cve) },
      { title: cve.hasErrata ? __('Yes') : __('No') },
      { title: hostCount(cve) },
    ],
    cve,
  }));

  const actions = [];

  return (
    <IndexTable
      columns={columns}
      rows={rows}
      actions={actions}
      pagination={props.pagination}
      totalCount={props.totalCount}
      history={props.history}
      ariaTableLabel={__('Table of CVEs')}
    />
  );
};

CvesTable.propTypes = {
  cves: PropTypes.array.isRequired,
  pagination: PropTypes.object.isRequired,
  totalCount: PropTypes.number.isRequired,
  history: PropTypes.object.isRequired,
  linkCell: PropTypes.func.isRequired,
};

export default withLoading(CvesTable);
