import React from 'react';
import PropTypes from 'prop-types';
import { Table, TableHeader, TableBody } from '@patternfly/react-table';
import { Flex, FlexItem } from '@patternfly/react-core';
import Pagination from 'foremanReact/components/Pagination';

const IndexTable = ({
  history,
  totalCount,
  toolbarBtns,
  ariaTableLabel,
  columns,
  ...rest
}) => (
  <React.Fragment>
    <Flex className="pf-u-pt-md">
      <FlexItem>{toolbarBtns}</FlexItem>
      <FlexItem align={{ default: 'alignRight' }}>
        <Pagination itemCount={totalCount} variant="top" />
      </FlexItem>
    </Flex>
    <Table
      aria-label={ariaTableLabel}
      cells={columns}
      {...rest}
      variant="compact"
    >
      <TableHeader />
      <TableBody />
    </Table>
  </React.Fragment>
);

IndexTable.propTypes = {
  history: PropTypes.object.isRequired,
  toolbarBtns: PropTypes.node,
  totalCount: PropTypes.number.isRequired,
  ariaTableLabel: PropTypes.string.isRequired,
  columns: PropTypes.array.isRequired,
};

IndexTable.defaultProps = {
  toolbarBtns: null,
};

export default IndexTable;
