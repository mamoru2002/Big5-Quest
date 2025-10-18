import React, { useEffect, useMemo, useRef } from 'react';
import { Chart } from 'chart.js/auto';

export default function TraitDeltaChart({ points = [] }) {
  const canvasRef = useRef(null);
  const chartRef = useRef(null);

  const data = useMemo(() => {
    const arr = Array.isArray(points)
      ? points
          .map(p => ({
            x: Number(p.week ?? p.x ?? 0),
            y: Number(p.delta ?? p.y ?? 0),
          }))
          .filter(p => Number.isFinite(p.x) && Number.isFinite(p.y))
      : [];
    if (!arr.some(p => p.x === 0)) arr.push({ x: 0, y: 0 });
    arr.sort((a, b) => a.x - b.x);
    return arr;
  }, [points]);

  const axisMax = useMemo(() => {
    const maxX = data.reduce((m, p) => (p.x > m ? p.x : m), 0);
    return Math.max(14, maxX);
  }, [data]);

  const pxPerWeek = 56;
  const contentMinWidth = (axisMax + 1) * pxPerWeek;

  const { yMin, yMax } = useMemo(() => {
    const ys = data.map(d => d.y);
    const rawMin = ys.length ? Math.min(...ys) : 0;
    const rawMax = ys.length ? Math.max(...ys) : 0;
    const absMax = Math.max(2, Math.abs(rawMin), Math.abs(rawMax));
    const toEvenUp = v => Math.ceil(v / 2) * 2;
    const yAbs = toEvenUp(absMax);
    return { yMin: -yAbs, yMax: yAbs };
  }, [data]);

  useEffect(() => {
    if (!canvasRef.current) return;

    if (chartRef.current) {
      chartRef.current.destroy();
      chartRef.current = null;
    }

    const ctx = canvasRef.current.getContext('2d');

    chartRef.current = new Chart(ctx, {
      type: 'line',
      data: {
        datasets: [
          {
            label: 'Δ score',
            data,
            borderColor: '#000000',
            borderWidth: 2,
            pointBackgroundColor: '#000000',
            pointRadius: 3,
            fill: false,
            tension: 0,
          },
        ],
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: {
          x: {
            type: 'linear',
            min: 0,
            max: axisMax,
            grid: { color: 'rgba(0,0,0,0.1)' },
            ticks: {
              stepSize: 1,
              callback: v => `W${v}`,
              color: '#2B3541',
            },
          },
          y: {
            min: yMin,
            max: yMax,
            ticks: { stepSize: 2, color: '#2B3541' },
            grid: { color: 'rgba(0,0,0,0.1)' },
          },
        },
        plugins: { legend: { display: false } },
      },
    });

    return () => {
      if (chartRef.current) {
        chartRef.current.destroy();
        chartRef.current = null;
      }
    };
  }, [data, axisMax, yMin, yMax]);

  return (
    <div className="w-full overflow-x-auto">
      <div className="lg:min-w-0" style={{ minWidth: contentMinWidth }}>
        <div style={{ height: 247 }}>
          <canvas ref={canvasRef} />
        </div>
      </div>
    </div>
  );
}