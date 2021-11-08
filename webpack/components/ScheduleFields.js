import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { Field as FormikField } from 'formik';

import { SelectField, TextField } from '../helpers/formFieldsHelper';

const ScheduleFields = ({ period, addBlanks }) => {
  const selectItems = [
    { id: 'weekly', name: __('Weekly') },
    { id: 'monthly', name: __('Monthly') },
    { id: 'custom', name: __('Custom') },
  ];

  let frequencyField;

  if (period === 'weekly') {
    const weekdays = [
      { id: 'sunday', name: __('Sunday') },
      { id: 'monday', name: __('Monday') },
      { id: 'tuesday', name: __('Tuesday') },
      { id: 'wednesday', name: __('Wednesday') },
      { id: 'thursday', name: __('Thursday') },
      { id: 'friday', name: __('Friday') },
      { id: 'saturday', name: __('Saturday') },
    ];

    frequencyField = (
      <FormikField
        label={__('Weekday')}
        name="weekday"
        selectItems={weekdays}
        blankLabel={addBlanks ? __('Choose weekday') : null}
        component={SelectField}
      />
    );
  }

  if (period === 'monthly') {
    const daysOfMonth = Array(31)
      .fill(1)
      .map((x, y) => x + y)
      .map(item => ({ id: item, name: item.toString() }));

    frequencyField = (
      <FormikField
        label={__('Day of month')}
        name="dayOfMonth"
        selectItems={daysOfMonth}
        blankLabel={addBlanks ? __('Choose day of month') : null}
        component={SelectField}
      />
    );
  }

  if (period === 'custom') {
    frequencyField = (
      <FormikField
        label={__('Cron Line')}
        name="cronLine"
        component={TextField}
      />
    );
  }

  return (
    <React.Fragment>
      <FormikField
        label={__('Period')}
        name="period"
        selectItems={selectItems}
        blankLabel={addBlanks ? __('Choose period') : null}
        component={SelectField}
      />
      {frequencyField}
    </React.Fragment>
  );
};

ScheduleFields.propTypes = {
  period: PropTypes.string.isRequired,
  addBlanks: PropTypes.bool,
};

ScheduleFields.defaultProps = {
  addBlanks: true,
};

export default ScheduleFields;
