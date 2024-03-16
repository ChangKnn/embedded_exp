var dom = document.getElementById('chart-container');
var myChart = echarts.init(dom, null, {
  renderer: 'canvas',
  useDirtyRect: false
});
var app = {};

var option;

var data = [];
// Parametric curve

// helper function: log message to screen
function log(msg) {
  document.getElementById('log').textContent += msg + '\n';
}

function addTable(x, y, z) {
  var td_x = document.createElement("td");
  var text_x = document.createTextNode(x);
  td_x.appendChild(text_x);
  var td_y = document.createElement("td");
  var text_y = document.createTextNode(y);
  td_y.appendChild(text_y);
  var td_z = document.createElement("td");
  var text_z = document.createTextNode(z);
  td_z.appendChild(text_z);

  var tr = document.createElement("tr");
  tr.appendChild(td_x);
  tr.appendChild(td_y);
  tr.appendChild(td_z);

  var table = document.getElementById('tableXYZ');
  table.appendChild(tr);
}

function start() {
  const btnStart = document.getElementById("start");
  const btnStop = document.getElementById("stop");
  if (btnStart.innerText === "Start") {
    send('START');
    btnStart.disabled = true;
    btnStop.disabled = false;
  } else {
    location.reload();
  }
}

function stop() {
  const btnStart = document.getElementById("start");
  const btnStop = document.getElementById("stop");
  send('STOP');
  btnStop.disabled = true;
  btnStart.innerText = "Restart";
  btnStart.disabled = false;
}

function errorAlert(msg) {
  window.alert(msg);
}

function send(msg) {
  if (ws) {
    try {
      ws.send(msg);
    } catch (ex) {
      window.alert(ex);
    }
  } else {
    window.alert('Cannot send: Not connected');
  }
}

//get data
var ws = new WebSocket('ws://192.168.2.238:9001/');
ws.onmessage = function (event) {
  var strs = new Array();
  strs = event.data.split(",");
  addTable(strs[0], strs[1], strs[2]);
  data.push(strs);
  if (option && typeof option === 'object') {
    myChart.setOption(option);
  }
};


console.log(data.length);
option = {
  tooltip: {},
  backgroundColor: '#fff',
  visualMap: {
    show: false,
    dimension: 2,
    min: 0,
    max: 250,
    inRange: {
      color: [
        '#313695',
        '#4575b4',
        '#74add1',
        '#abd9e9',
        '#e0f3f8',
        '#ffffbf',
        '#fee090',
        '#fdae61',
        '#f46d43',
        '#d73027',
        '#a50026'
      ]
    }
  },
  xAxis3D: {
    type: 'value'
  },
  yAxis3D: {
    type: 'value'
  },
  zAxis3D: {
    type: 'value'
  },
  grid3D: {
    viewControl: {
      projection: 'orthographic'
    }
  },
  series: [
    {
      type: 'line3D',
      data: data,
      lineStyle: {
        width: 4
      }
    }
  ]
};

if (option && typeof option === 'object') {
  myChart.setOption(option);
}

window.addEventListener('resize', myChart.resize);
