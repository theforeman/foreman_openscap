import React, {
  useMemo,
  useRef,
  useEffect,
  useLayoutEffect,
  useState,
  useCallback,
} from 'react';
import PropTypes from 'prop-types';
import {
  Chart,
  ChartAxis,
  ChartGroup,
  ChartLine,
  ChartLegend,
  ChartLegendTooltip,
  ChartThemeColor,
  createContainer,
} from '@patternfly/react-charts/victory';

import { translate as __ } from 'foremanReact/common/I18n';
import {
  formatAxisTick,
  formatTooltipTitle,
  formatYAxisTick,
  getLegendEvents,
  getSeriesOpacity,
  getXAxisTickValues,
  InteractiveLegendLabel,
  InteractiveLegendSymbol,
  XAxisTickLabel,
} from 'foremanReact/components/common/charts/helpers/LegendHelpers';
import EmptyState from '../EmptyState';

import {
  processChartData,
  hasChartData,
  getYTickValues,
  sanitizeChartDimension,
  clampChartPadding,
  getTimeseriesXDomain,
  buildLineChartLegendData,
  formatTooltipValue,
} from './LineChartHelpers';
import './LineChart.scss';

const DEFAULT_HEIGHT = 350;
const DEFAULT_WIDTH = 1000;

/** Match AreaChart padding so angled x-axis tick labels are not clipped. */
const CHART_PADDING_BASE = { bottom: 125, right: 170, top: 50 };

const getDataClickEvents = onclick => {
  if (!onclick) return null;

  return {
    target: 'data',
    eventHandlers: {
      onClick: () => [
        {
          target: 'data',
          mutation: props => {
            if (props.datum?.name) {
              onclick({ id: props.datum.name });
            }
            return null;
          },
        },
      ],
    },
  };
};

const LineChart = ({
  data,
  config,
  noDataMsg,
  xAxisDataLabel,
  onclick,
  id,
  size,
  title: _title,
  unloadData: _unloadData,
  axisOpts: _axisOpts,
}) => {
  const chartData = useMemo(
    () => processChartData(data, xAxisDataLabel, config),
    [data, xAxisDataLabel, config]
  );

  const CursorVoronoiContainer = useMemo(
    () => createContainer('voronoi', 'cursor'),
    []
  );

  const [hiddenSeries, setHiddenSeries] = useState(() => new Set());
  const [hoveredSeries, setHoveredSeries] = useState(null);
  const toggleSeries = useCallback(name => {
    setHiddenSeries(prev => {
      const next = new Set(prev);
      if (next.has(name)) next.delete(name);
      else next.add(name);
      return next;
    });
  }, []);

  const containerRef = useRef(null);
  const [observedSize, setObservedSize] = useState(null);

  const updateObservedSize = useCallback(() => {
    const el = containerRef.current;
    if (!el) return;

    const { width, height } = el.getBoundingClientRect();
    if (width > 0 && height > 0) {
      setObservedSize({ width, height });
    }
  }, []);

  useLayoutEffect(() => {
    updateObservedSize();
  }, [updateObservedSize]);

  useEffect(() => {
    const el = containerRef.current;
    if (!el || typeof ResizeObserver === 'undefined') return undefined;

    const observer = new ResizeObserver(() => {
      updateObservedSize();
    });

    observer.observe(el);
    return () => observer.disconnect();
  }, [updateObservedSize]);

  const legendData = useMemo(
    () => (chartData ? buildLineChartLegendData(chartData, hiddenSeries) : []),
    [chartData, hiddenSeries]
  );

  const visibleSeries = useMemo(
    () => chartData?.filter(series => !hiddenSeries.has(series.name)) ?? [],
    [chartData, hiddenSeries]
  );

  const tickValues = useMemo(() => getXAxisTickValues(chartData, 6), [
    chartData,
  ]);
  const yTickValues = useMemo(() => getYTickValues(chartData, hiddenSeries), [
    chartData,
    hiddenSeries,
  ]);
  const timeseriesXDomain = useMemo(
    () =>
      config === 'timeseries' ? getTimeseriesXDomain(chartData) : undefined,
    [chartData, config]
  );

  if (!hasChartData(data, xAxisDataLabel) || !chartData) {
    return (
      <EmptyState
        ouiaEmptyStateTitleId="openscap-line-chart-empty-state-title"
        title={noDataMsg}
      />
    );
  }

  const hasExplicitSize = size?.width > 0 && size?.height > 0;
  if (!hasExplicitSize && !observedSize) {
    return <div ref={containerRef} className="line-chart-container" />;
  }

  const maxTickLabelLen =
    yTickValues?.length > 0
      ? Math.max(...yTickValues.map(t => formatYAxisTick(t).length))
      : formatYAxisTick(0).length;
  const dynamicLeft = maxTickLabelLen * 8 + 50;
  const chartHeight = sanitizeChartDimension(
    size?.height ?? observedSize?.height,
    DEFAULT_HEIGHT
  );
  const chartWidth = sanitizeChartDimension(
    size?.width ?? observedSize?.width,
    DEFAULT_WIDTH
  );
  const padding = clampChartPadding(
    {
      ...CHART_PADDING_BASE,
      left: dynamicLeft,
    },
    chartWidth,
    chartHeight
  );
  const chartName = id || 'line-chart';
  const legendEvents = getLegendEvents(chartName, toggleSeries);
  const events = [getDataClickEvents(onclick), legendEvents].filter(Boolean);

  return (
    <div ref={containerRef} className="line-chart-container">
      <Chart
        name={chartName}
        ariaDesc={__('Line chart')}
        themeColor={ChartThemeColor.multi}
        animate={false}
        domainPadding={{ x: [20, 20], y: [10, 10] }}
        scale={config === 'timeseries' ? { x: 'time' } : undefined}
        containerComponent={
          <CursorVoronoiContainer
            cursorDimension="x"
            labels={({ datum }) => formatTooltipValue(datum.y)}
            labelComponent={
              <ChartLegendTooltip
                legendData={legendData}
                title={formatTooltipTitle}
              />
            }
            mouseFollowTooltips
            voronoiDimension="x"
            voronoiPadding={padding}
            constrainToVisibleArea
          />
        }
        height={chartHeight}
        width={chartWidth}
        padding={padding}
        legendData={legendData}
        legendOrientation="vertical"
        legendPosition="right"
        legendComponent={
          <ChartLegend
            dataComponent={
              <InteractiveLegendSymbol
                setHoveredSeries={setHoveredSeries}
                toggleSeries={toggleSeries}
              />
            }
            labelComponent={
              <InteractiveLegendLabel
                hiddenSeries={hiddenSeries}
                hoveredSeries={hoveredSeries}
                setHoveredSeries={setHoveredSeries}
                toggleSeries={toggleSeries}
              />
            }
          />
        }
        events={events}
      >
        <ChartAxis
          tickValues={config === 'timeseries' ? tickValues : undefined}
          tickFormat={config === 'timeseries' ? formatAxisTick : undefined}
          domain={timeseriesXDomain}
          tickLabelComponent={
            config === 'timeseries' ? (
              <XAxisTickLabel yAxisLabelOffset={-12} />
            ) : (
              undefined
            )
          }
          style={
            config === 'timeseries'
              ? { tickLabels: { angle: -45, verticalAnchor: 'end' } }
              : undefined
          }
        />
        <ChartAxis
          dependentAxis
          showGrid
          tickValues={yTickValues}
          tickFormat={formatYAxisTick}
        />
        <ChartGroup>
          {visibleSeries.map(series => (
            <ChartLine
              key={series.name}
              name={series.name}
              data={series.data}
              style={{
                data: {
                  ...(series.color && { stroke: series.color }),
                  opacity: getSeriesOpacity(
                    hoveredSeries && hoveredSeries !== series.name
                  ),
                },
              }}
            />
          ))}
        </ChartGroup>
      </Chart>
    </div>
  );
};

LineChart.propTypes = {
  data: PropTypes.oneOfType([PropTypes.object, PropTypes.array]),
  config: PropTypes.oneOf(['regular', 'timeseries']),
  noDataMsg: PropTypes.string,
  xAxisDataLabel: PropTypes.string,
  onclick: PropTypes.func,
  id: PropTypes.string,
  size: PropTypes.shape({
    height: PropTypes.number,
    width: PropTypes.number,
  }),
  // Accepted for compatibility with the legacy Foreman wrapper; unused in PF5.
  title: PropTypes.object,
  unloadData: PropTypes.bool,
  axisOpts: PropTypes.object,
};

LineChart.defaultProps = {
  data: undefined,
  config: 'regular',
  noDataMsg: __('No data available'),
  xAxisDataLabel: '',
  onclick: undefined,
  id: undefined,
  size: undefined,
  title: { type: 'percent' },
  unloadData: false,
  axisOpts: {},
};

export default LineChart;
