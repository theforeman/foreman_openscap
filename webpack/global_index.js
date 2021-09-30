import React from 'react';

import { addGlobalFill } from 'foremanReact/components/common/Fill/GlobalFill';
import { registerRoutes } from 'foremanReact/routes/RoutingService';
import { openscapPath } from './components/OpenscapHostDetail/OpenscapHostDetailHelper';

import routes from './routes/routes';
import OpenscapHostDetail from './components/OpenscapHostDetail';

registerRoutes('foreman_openscap', routes);

addGlobalFill(
  'host-details-page-tabs',
  openscapPath,
  <OpenscapHostDetail key="openscap-host-detail" />,
  450
);
