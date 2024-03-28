import {
  selectAPIError,
  selectAPIResponse,
  selectAPIStatus,
} from 'foremanReact/redux/API/APISelectors';
import { STATUS } from 'foremanReact/constants';
import { REPORT_LOG_REQUEST_KEY } from './constants';

export const selectLogResponse = state =>
  selectAPIResponse(state, REPORT_LOG_REQUEST_KEY);

export const selectLogStatus = state =>
  selectAPIStatus(state, REPORT_LOG_REQUEST_KEY) || STATUS.PENDING;

export const selectLogError = state =>
  selectAPIError(state, REPORT_LOG_REQUEST_KEY);
