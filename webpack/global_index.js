import React from 'react';
import { registerRoutes } from 'foremanReact/routes/RoutingService';
import { addGlobalFill } from 'foremanReact/components/common/Fill/GlobalFill';
import HostKebabItems from './components/HostExtentions/HostKebabItems';
import routes from './routes/routes';

registerRoutes('foreman_openscap', routes);

addGlobalFill(
  'host-details-kebab',
  `openscap-kebab-items`,
  <HostKebabItems key="openscap-host-kebab" />,
  400
);
