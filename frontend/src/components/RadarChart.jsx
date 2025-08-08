import React, { useEffect, useRef } from 'react';
import { Chart } from 'chart.js/auto';

export default function RadarChart({ scores }) {
  const chartRef = useRef(null);

  useEffect(() => {
    if (!chartRef.current) return;

    const ctx = chartRef.current.getContext('2d');

    const labels = ['情緒安定性', '外向性', '開放性', '協調性', '誠実性'];
    const traitOrder = ['N', 'E', 'O', 'A', 'C'];
    const dataValues = traitOrder.map(code => scores[code] ?? 0);

    new Chart(ctx, {
      type: 'radar',
      data: {
        labels,
        datasets: [
          {
            label: '診断結果',
            data: dataValues,
            backgroundColor: 'rgba(0, 168, 165, 0.2)',
            borderColor: '#2B3541',
            borderWidth: 2,
            pointBackgroundColor: '#2B3541',
          },
        ],
      },
      options: {
        responsive: true,
        scales: {
          r: {
            suggestedMin: 0,
            suggestedMax: 5,
            ticks: {
              stepSize: 1,
              color: '#2B3541',
            },
            grid: {
              color: 'rgba(0,0,0,0.1)',
            },
            pointLabels: {
              color: '#2B3541',
              font: {
                size: 14,
              },
            },
          },
        },
        plugins: {
          legend: { display: false },
        },
      },
    });
  }, [scores]);

  return <canvas ref={chartRef} width={400} height={400}></canvas>;
}