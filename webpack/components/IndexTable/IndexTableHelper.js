import { addSearch } from '../../helpers/pageParamsHelper';

export const refreshPage = (history, params = {}) => {
  const url = addSearch(history.location.pathname, params);
  history.push(url);
};
