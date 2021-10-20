import { addToast } from 'foremanReact/components/ToastsList';

export const showToast = dispatch => toast => dispatch(addToast(toast));
