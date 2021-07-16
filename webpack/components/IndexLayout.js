import React, { useState } from 'react';
import { useDispatch } from 'react-redux';
import PropTypes from 'prop-types';
import { Helmet } from 'react-helmet';
import {
  Grid,
  GridItem,
  TextContent,
  Text,
  TextVariants,
} from '@patternfly/react-core';

import ConfirmModal from './ConfirmModal';
import { showToast } from '../helpers/toastHelper';

import './IndexLayout.scss';

const IndexLayout = ({
  pageTitle,
  children,
  toolbarBtns,
  contentWidthSpan,
}) => {
  const [modalState, setModalState] = useState({
    prepareMutation: () => [() => {}, { loading: false }],
    onConfirm: () => {},
    onClose: () => updateModalState({ isOpen: false }),
    title: 'Empty title',
    text: '',
    isOpen: false,
    record: {},
  });

  const dispatch = useDispatch();

  const updateModalState = newAttrs =>
    setModalState({ ...modalState, ...newAttrs });

  return (
    <React.Fragment>
      <Helmet>
        <title>{pageTitle}</title>
      </Helmet>
      <Grid className="scap-page-grid">
        <GridItem span={8}>
          <TextContent>
            <Text component={TextVariants.h1}>{pageTitle}</Text>
          </TextContent>
        </GridItem>
        {toolbarBtns &&
          toolbarBtns({
            updateModalState,
            modalState,
            showToast: showToast(dispatch),
          })}
        <GridItem span={4} />
        <GridItem span={contentWidthSpan}>{children}</GridItem>
      </Grid>
      <ConfirmModal {...modalState} />
    </React.Fragment>
  );
};

IndexLayout.propTypes = {
  pageTitle: PropTypes.string.isRequired,
  children: PropTypes.oneOfType([PropTypes.object, PropTypes.node]).isRequired,
  toolbarBtns: PropTypes.func,
  contentWidthSpan: PropTypes.number,
};

IndexLayout.defaultProps = {
  toolbarBtns: null,
  contentWidthSpan: 12,
};

export default IndexLayout;
