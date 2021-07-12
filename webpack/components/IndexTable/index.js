import React from 'react';
import PropTypes from 'prop-types';
import { Table, TableHeader, TableBody } from '@patternfly/react-table';
import { Pagination, Flex, FlexItem } from '@patternfly/react-core';
import { usePaginationOptions } from 'foremanReact/components/Pagination/PaginationHooks';

import { preparePerPageOptions, refreshPage } from './IndexTableHelper';

const IndexTable = ({
  history,
  pagination,
  totalCount,
  toolbarBtns,
  ariaTableLabel,
  columns,
  ...rest
}) => {
  const handlePerPageSelected = (event, perPage) => {
    refreshPage(history, { page: 1, perPage });
  };

  const handlePageSelected = (event, page) => {
    refreshPage(history, { ...pagination, page });
  };

  const perPageOptions = preparePerPageOptions(usePaginationOptions());

  return (
    <React.Fragment>
      <Flex className="pf-u-pt-md">
        <FlexItem>{toolbarBtns}</FlexItem>
        <FlexItem align={{ default: 'alignRight' }}>
          <Pagination
            itemCount={totalCount}
            page={pagination.page}
            perPage={pagination.perPage}
            onSetPage={handlePageSelected}
            onPerPageSelect={handlePerPageSelected}
            perPageOptions={perPageOptions}
            variant="top"
          />
        </FlexItem>
      </Flex>
      <Table aria-label={ariaTableLabel} cells={columns} {...rest}>
        <TableHeader />
        <TableBody />
      </Table>
    </React.Fragment>
  );
};

IndexTable.propTypes = {
  history: PropTypes.object.isRequired,
  pagination: PropTypes.object.isRequired,
  toolbarBtns: PropTypes.array,
  totalCount: PropTypes.number.isRequired,
  ariaTableLabel: PropTypes.string.isRequired,
  columns: PropTypes.array.isRequired,
};

IndexTable.defaultProps = {
  toolbarBtns: [],
};

export default IndexTable;
