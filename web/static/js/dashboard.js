import $ from 'jquery';
window.jQuery = $;
window.$ = $;
require('bootstrap-sass');
require('admin-lte');
import Chart from 'chart.js';

class App {
  render() {
    this.renderRequestsChart();
  }

  renderRequestsChart() {
    const ctx = $('#requests-chart canvas');
    console.log('da', ctx.data('points'));


    new Chart(ctx, {
      type: 'bar',
      data: {
        labels : [...Array(100).keys()],
        datasets: [{
          label : 'Request time',
          backgroundColor: 'rgba(60,141,188,0.9)',
          borderColor: 'rgba(60,141,188,0.8)',
          data : ctx.data('points')
        }
        ]
      },
      options: {
        legend: {
          display: false
        },
        scales: {
          xAxes: [{
            display: false
          }],
          yAxes: [{
            scaleLabel: {
              display: true,
              labelString: 'µs'
            },
            ticks: {
              max: ctx.data('max'),
              min: 0
            }
          }],
        },
        tooltips: {
          callbacks: {
            label: (item, data) => {
              const dataset = data.datasets[item.datasetIndex];
              const value = dataset.data[item.index];
              return `${dataset.label}: ${value}µs`
            }, 
            title: () => {}
          },
          yAlign: 'top'
        },
        maintainAspectRatio: false
      }
    });
  }
}

(new App()).render();
