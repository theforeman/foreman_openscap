import React, { useContext, useState, useEffect } from 'react';
import PropTypes from 'prop-types';
import {
  Spinner,
  Toolbar,
  ToolbarContent,
  ToolbarGroup,
  ToolbarItem,
} from '@patternfly/react-core';
import { Td } from '@patternfly/react-table';

import { foremanUrl, noop } from 'foremanReact/common/helpers';
import { translate as __ } from 'foremanReact/common/I18n';
import SelectAllCheckbox from 'foremanReact/components/PF4/TableIndexPage/Table/SelectAllCheckbox';
import { Table } from 'foremanReact/components/PF4/TableIndexPage/Table/Table';
import { useBulkSelect } from 'foremanReact/components/PF4/TableIndexPage/Table/TableHooks';
import { getPageStats } from 'foremanReact/components/PF4/TableIndexPage/Table/helpers';
import { STATUS } from 'foremanReact/constants';
import { useAPI } from 'foremanReact/common/hooks/API/APIHooks';

import OpenscapRemediationWizardContext from '../OpenscapRemediationWizardContext';
import WizardHeader from '../WizardHeader';
import {
  HOSTS_API_PATH,
  HOSTS_API_REQUEST_KEY,
  FAIL_RULE_SEARCH,
} from '../constants';

const ReviewHosts = () => {
  const { source, hostId, setHostIdsParam } = useContext(
    OpenscapRemediationWizardContext
  );

  const defaultSearch = `${FAIL_RULE_SEARCH} = ${source}`;
  const defaultParams = {
    search: defaultSearch,
  };

  const [params, setParams] = useState(defaultParams);

  const response = useAPI('get', `${HOSTS_API_PATH}?include_permissions=true`, {
    key: HOSTS_API_REQUEST_KEY,
    params: defaultParams,
  });
  const {
    response: {
      search: apiSearchQuery,
      results,
      per_page: perPage,
      page,
      subtotal,
      message: errorMessage,
    },
    status = STATUS.PENDING,
    setAPIOptions,
  } = response;

  const subtotalCount = Number(subtotal ?? 0);

  const setParamsAndAPI = newParams => {
    setParams(newParams);
    setAPIOptions({ key: HOSTS_API_REQUEST_KEY, params: newParams });
  };

  const { pageRowCount } = getPageStats({
    total: subtotalCount,
    page,
    perPage,
  });
  const { fetchBulkParams, ...selectAllOptions } = useBulkSelect({
    results,
    metadata: { total: subtotalCount, page },
    initialSearchQuery: apiSearchQuery || defaultSearch,
    isSelectable: () => true,
    initialArry: [hostId],
  });
  const {
    selectPage,
    selectedCount,
    selectOne,
    selectNone,
    selectAll,
    areAllRowsOnPageSelected,
    areAllRowsSelected,
    isSelected,
  } = selectAllOptions;

  useEffect(() => {
    if (selectedCount) setHostIdsParam(fetchBulkParams());
  }, [selectedCount, fetchBulkParams, setHostIdsParam]);

  const selectionToolbar = (
    <ToolbarItem key="selectAll">
      <SelectAllCheckbox
        {...{
          selectAll, // I don't think it really can select all since ids from other pages are still need to be loaded/fetched
          selectPage,
          selectNone: () => {
            selectNone();
            selectOne(true, hostId);
          },
          selectedCount,
          pageRowCount,
        }}
        totalCount={subtotalCount}
        areAllRowsOnPageSelected={areAllRowsOnPageSelected()}
        areAllRowsSelected={areAllRowsSelected()}
      />
    </ToolbarItem>
  );

  const RowSelectTd = ({ rowData }) => (
    <Td
      select={{
        rowIndex: rowData.id,
        onSelect: (_event, isSelecting) => {
          selectOne(isSelecting, rowData.id);
        },
        isSelected: rowData.id === hostId || isSelected(rowData.id),
        disable: rowData.id === hostId || false,
      }}
    />
  );
  RowSelectTd.propTypes = {
    rowData: PropTypes.object.isRequired,
  };

  const columns = {
    name: {
      title: __('Name'),
      wrapper: ({ id, name }) => <a href={foremanUrl(`hosts/${id}`)}>{name}</a>,
      isSorted: true,
    },
    operatingsystem_name: {
      title: __('OS'),
    },
  };

  return (
    <>
      <WizardHeader
        title={__('Review hosts')}
        description={__(
          'The remediation will be applied to the current host by default. Here you can select additional hosts which fail the same rule.'
        )}
      />
      <Toolbar ouiaId="table-toolbar" className="table-toolbar">
        <ToolbarContent>
          <ToolbarGroup>
            {selectionToolbar}
            {status === STATUS.PENDING && (
              <ToolbarItem>
                <Spinner size="sm" />
              </ToolbarItem>
            )}
          </ToolbarGroup>
        </ToolbarContent>
      </Toolbar>
      <Table
        isEmbedded
        params={params}
        setParams={setParamsAndAPI}
        itemCount={subtotalCount}
        results={results}
        url={HOSTS_API_PATH}
        refreshData={() =>
          setAPIOptions({
            key: HOSTS_API_REQUEST_KEY,
            params: { defaultSearch },
          })
        }
        columns={columns}
        errorMessage={
          status === STATUS.ERROR && errorMessage ? errorMessage : null
        }
        isPending={status === STATUS.PENDING}
        showCheckboxes
        rowSelectTd={RowSelectTd}
      />
    </>
  );
};

export default ReviewHosts;
