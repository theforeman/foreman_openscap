import React from 'react';
import { addGlobalFill } from 'foremanReact/components/common/Fill/GlobalFill';
import HostKebabItems from './components/HostExtentions/HostKebabItems';

addGlobalFill(
  'host-details-kebab',
  `openscap-kebab-items`,
  <HostKebabItems key="openscap-host-kebab" />,
  400
);
