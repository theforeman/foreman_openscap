import { decodeModelId } from './globalIdHelper';

const showPath = path => `${path}/:id`;
const newPath = path => `${path}/new`;

export const modelPath = (basePath, model) =>
  `${basePath}/${decodeModelId(model)}`;

// react-router uses path-to-regexp, should we use it as well in a future?
// https://github.com/pillarjs/path-to-regexp/tree/v1.7.0#compile-reverse-path-to-regexp
export const resolvePath = (path, params) =>
  Object.entries(params).reduce(
    (memo, [key, value]) => memo.replace(key, value),
    path
  );

export const hostsPath = '/hosts';
export const newJobPath = newPath('/job_invocations');
export const hostsShowPath = showPath(hostsPath);
