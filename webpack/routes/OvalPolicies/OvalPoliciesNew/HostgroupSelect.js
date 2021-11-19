import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { useLazyQuery } from '@apollo/client';
import { translate as __, sprintf } from 'foremanReact/common/I18n';
import {
  Select,
  SelectOption,
  SelectVariant,
  FormGroup,
} from '@patternfly/react-core';
import { ExclamationCircleIcon } from '@patternfly/react-icons';
import hostgroupsQuery from '../../../graphql/queries/hostgroups.gql';

const HostgroupSelect = ({
  selected,
  setSelected,
  hgsError,
  showError,
  setShowError,
}) => {
  const [isOpen, setIsOpen] = useState(false);

  const [typingTimeout, setTypingTimeout] = useState(null);

  const [fetchHostgroups, { loading, data, error }] = useLazyQuery(
    hostgroupsQuery
  );
  const results = data?.hostgroups?.nodes ? data.hostgroups.nodes : [];

  const onSelect = (event, selection) => {
    if (selected.find(item => item.name === selection)) {
      setSelected(selected.filter(item => item.name !== selection));
    } else {
      const hg = results.find(item => item.name === selection);
      setSelected([...selected, hg]);
    }
  };

  const onClear = () => {
    if (showError) {
      setShowError(false);
    }
    setSelected([]);
  };

  const onInputChange = value => {
    if (showError) {
      setShowError(false);
    }
    if (typingTimeout) {
      clearTimeout(typingTimeout);
    }
    const variables = { search: `name ~ ${value}` };
    setTypingTimeout(setTimeout(() => fetchHostgroups({ variables }), 500));
  };

  const shouldValidate = (err, shouldShowError) => {
    if (shouldShowError) {
      return err ? 'error' : 'success';
    }
    return 'noval';
  };

  const prepareOptions = fetchedResults => {
    if (loading) {
      return [
        <SelectOption isDisabled key={0}>
          {__('Loading...')}
        </SelectOption>,
      ];
    }

    if (error) {
      return [
        <SelectOption isDisabled key={0}>
          {sprintf('Failed to fetch hostgroups, cause: %s', error.message)}
        </SelectOption>,
      ];
    }

    if (fetchedResults.length > 20) {
      return [
        <SelectOption isDisabled key={0}>
          {sprintf(
            'You have %s hostgroups to display. Please refine your search.',
            fetchedResults.length
          )}
        </SelectOption>,
      ];
    }

    return fetchedResults.map((hg, idx) => (
      <SelectOption key={hg.id} value={hg.name} />
    ));
  };

  return (
    <FormGroup
      label={__('Hostgroups')}
      helperTextInvalidIcon={<ExclamationCircleIcon />}
      helperTextInvalid={showError && hgsError}
      validated={shouldValidate(hgsError, showError)}
    >
      <Select
        variant={SelectVariant.typeaheadMulti}
        typeAheadAriaLabel="Select a hostgroup"
        placeholderText="Type a hostroup name..."
        onToggle={() => setIsOpen(!isOpen)}
        onSelect={onSelect}
        onClear={onClear}
        selections={selected.map(item => item.name)}
        isOpen={isOpen}
        onTypeaheadInputChanged={onInputChange}
        validated={shouldValidate(hgsError, showError)}
      >
        {prepareOptions(results)}
      </Select>
    </FormGroup>
  );
};

HostgroupSelect.propTypes = {
  selected: PropTypes.array,
  setSelected: PropTypes.func.isRequired,
  hgsError: PropTypes.string,
  showError: PropTypes.bool.isRequired,
  setShowError: PropTypes.func.isRequired,
};

HostgroupSelect.defaultProps = {
  selected: [],
  hgsError: '',
};

export default HostgroupSelect;
