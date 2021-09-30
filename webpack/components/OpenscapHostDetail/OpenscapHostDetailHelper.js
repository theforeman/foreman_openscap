export const openscapPath = 'Compliance';

export const hashRoute = subpath => `#/${openscapPath}/${subpath}`;
export const route = subpath => hashRoute(subpath).substring(1);

export const setActiveKey = location => location.pathname?.split('/')[2];
