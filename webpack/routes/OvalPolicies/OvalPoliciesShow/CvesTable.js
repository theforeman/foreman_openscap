import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';

import { linkCell } from '../../../helpers/tableHelper';
import { hostsPath } from '../../../helpers/pathsHelper';
import { decodeModelId } from '../../../helpers/globalIdHelper';
import { addSearch } from '../../../helpers/pageParamsHelper';

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
    linkCell(
      addSearch(hostsPath, { search: `cve_id = ${decodeModelId(cve)}` }),
      cve.hosts.nodes.length
    );

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
      ariaTableLabel={__('Table of CVEs for OVAL policy')}
    />
  );
};

CvesTable.propTypes = {
  cves: PropTypes.array.isRequired,
  pagination: PropTypes.object.isRequired,
  totalCount: PropTypes.number.isRequired,
  history: PropTypes.object.isRequired,
};

export default withLoading(CvesTable);
