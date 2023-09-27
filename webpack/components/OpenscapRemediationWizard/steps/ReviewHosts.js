import React, { useContext, useState, useEffect, useCallback } from 'react';
import { map, includes, without, union } from 'lodash';
import {
  Spinner,
  Toolbar,
  ToolbarContent,
  ToolbarGroup,
  ToolbarItem,
  Dropdown,
  DropdownToggle,
  DropdownToggleCheckbox,
  DropdownItem,
  Checkbox,
} from '@patternfly/react-core';

import { sprintf, translate as __ } from 'foremanReact/common/I18n';
import SearchBar from 'foremanReact/components/SearchBar';
import { Table } from 'foremanReact/components/PF4/TableIndexPage/Table/Table';
import { getControllerSearchProps, STATUS } from 'foremanReact/constants';
import { useAPI } from 'foremanReact/common/hooks/API/APIHooks';
import { useForemanSettings } from 'foremanReact/Root/Context/ForemanContext';

import OpenscapRemediationWizardContext from '../OpenscapRemediationWizardContext';
import WizardHeader from '../WizardHeader';
import {
  HOSTS_API_PATH,
  HOSTS_API_REQUEST_KEY,
  FAIL_RULE_SEARCH,
} from '../constants';

const ReviewHosts = () => {
  const { source, setHostIds, hostIds } = useContext(
    OpenscapRemediationWizardContext
  );

  const defaultSearch = `${FAIL_RULE_SEARCH} = ${source}`;
  const defaultParams = {
    // TODO: for some reason pagination is visually broken
    search: defaultSearch,
    page: 1,
    per_page: useForemanSettings().perPage || 20,
  };

  const [params, setParams] = useState(defaultParams);
  const [isSelectDropdownOpen, setSelectDropdownOpen] = useState(false);
  const [selectionToggle, setSelectionToggle] = useState(false);

  const searchProps = getControllerSearchProps('hosts');
  searchProps.autocomplete.searchQuery = defaultSearch;
  searchProps.autocomplete.url = '../../hosts/auto_complete_search'; // TODO: find a way to not use relative path
  searchProps.disabled = true; // This is to force hosts to be searched by currently remediated rule only

  const {
    response: {
      search: apiSearchQuery,
      results,
      subtotal,
      message: errorMessage,
    },
    status = STATUS.PENDING,
    setAPIOptions,
  } = useAPI('get', `${HOSTS_API_PATH}?include_permissions=true`, {
    // TODO: verify permissions
    key: HOSTS_API_REQUEST_KEY,
    params,
  });

  const subtotalCount = Number(subtotal ?? 0);

  const setParamsAndAPI = newParams => {
    setParams(newParams);
    setAPIOptions({ key: HOSTS_API_REQUEST_KEY, params: newParams });
  };

  const onSearch = newSearch => {
    if (newSearch !== apiSearchQuery) {
      setParamsAndAPI({ ...params, search: newSearch, page: 1 });
    }
  };

  const onSelectCheckboxChange = checked => {
    if (checked && selectionToggle !== null) {
      handleSelectPage();
    } else {
      handleSelectNone();
    }
  };

  const isHostSelected = id => includes(hostIds, id);
  const selectHost = (id, selected) => {
    if (selected) {
      if (!isHostSelected(id)) {
        setHostIds(union(hostIds, [id]));
      }
    } else if (isHostSelected(id)) {
      setHostIds([...without(hostIds, id)]);
    }
  };
  const addHosts = ids => {
    setHostIds(union(hostIds, ids));
  };

  const handleSelectPage = () => {
    setSelectDropdownOpen(false);
    setSelectionToggle(true);
    addHosts(map(results, h => h.id));
  };

  const handleSelectNone = () => {
    setSelectDropdownOpen(false);
    setSelectionToggle(false);
    setHostIds([]);
  };

  const areAllRowsSelected = useCallback(
    () => subtotalCount === hostIds.length,
    [subtotalCount, hostIds]
  );

  useEffect(() => {
    let newCheckedState = null; // null is partially-checked state

    if (areAllRowsSelected()) {
      newCheckedState = true;
    } else if (hostIds.length === 0) {
      newCheckedState = false;
    }
    setSelectionToggle(newCheckedState);
  }, [hostIds, areAllRowsSelected]);

  const getPageRowCount = (total, page, perPage) => {
    // logic adapted from patternfly so that we can know the number of items per page
    const lastPage = Math.ceil(total / perPage) ?? 0;
    const firstIndex = total <= 0 ? 0 : (page - 1) * perPage + 1;
    let lastIndex;
    if (total <= 0) {
      lastIndex = 0;
    } else {
      lastIndex = page === lastPage ? total : page * perPage;
    }
    let pageRowCount = lastIndex - firstIndex + 1;
    if (total <= 0) pageRowCount = 0;
    return pageRowCount;
  };

  const selectDropdownItems = [
    <DropdownItem
      key="select-none"
      ouiaId="select-none"
      component="button"
      isDisabled={hostIds.length === 0}
      onClick={handleSelectNone}
    >
      {`${__('Select none')} (0)`}
    </DropdownItem>,
    <DropdownItem
      key="select-page"
      ouiaId="select-page"
      component="button"
      isDisabled={subtotalCount === 0 || areAllRowsSelected()}
      onClick={handleSelectPage}
    >
      {`${__('Select page')} (${getPageRowCount(
        subtotal,
        params.page,
        params.per_page
      )})`}
    </DropdownItem>,
  ];

  const columns = {
    selected: {
      title: '',
      wrapper: ({ id }) => (
        <Checkbox
          ouiaId={`select-host-${id}`}
          id={id}
          aria-label={`Select host ${id}`}
          isChecked={isHostSelected(id)}
          onChange={selected => selectHost(id, selected)}
        />
      ),
    },
    name: {
      title: __('Name'),
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
          'The remediation will be applied to the current host by default. Here you can select additional hosts.'
        )}
      />
      <Toolbar ouiaId="table-toolbar" className="table-toolbar">
        <ToolbarContent>
          <ToolbarGroup>
            <ToolbarItem>
              <Dropdown
                toggle={
                  <DropdownToggle
                    onToggle={() => setSelectDropdownOpen(isOpen => !isOpen)}
                    id="select-all-checkbox-dropdown-toggle"
                    ouiaId="select-all-checkbox-dropdown-toggle"
                    splitButtonItems={[
                      <DropdownToggleCheckbox
                        key="tablewrapper-select-all-checkbox"
                        ouiaId="select-all-checkbox-dropdown-toggle-checkbox"
                        aria-label="Select all"
                        onChange={checked => onSelectCheckboxChange(checked)}
                        isChecked={selectionToggle}
                        isDisabled={subtotalCount === 0 && hostIds.length === 0}
                      >
                        {hostIds.length > 0 &&
                          sprintf(__('%s selected'), hostIds.length)}
                      </DropdownToggleCheckbox>,
                    ]}
                  />
                }
                isOpen={isSelectDropdownOpen}
                dropdownItems={selectDropdownItems}
                id="selection-checkbox"
                ouiaId="selection-checkbox"
              />
            </ToolbarItem>
            <ToolbarItem className="toolbar-search">
              <SearchBar
                data={searchProps}
                initialQuery={apiSearchQuery}
                onSearch={onSearch}
              />
            </ToolbarItem>
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
        isActionable={false}
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
      />
    </>
  );
};

export default ReviewHosts;
