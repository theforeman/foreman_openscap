import { last } from './commonHelper';

const idSeparator = '-';
const versionSeparator = ':';
const defaultVersion = '01';

export const decodeModelId = model => decodeId(model.id);

export const decodeId = globalId => {
  const split = atob(globalId).split(idSeparator);
  return parseInt(last(split), 10);
};

export const encodeId = (typename, id) =>
  btoa([defaultVersion, versionSeparator, typename, idSeparator, id].join(''));
