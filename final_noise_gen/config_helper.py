import numpy as np
import json

# generating sensor coords in circle
n_sensors = 8
phase = np.linspace(0, 2*np.pi, n_sensors+1)[:-1]
r = .5 # radius in meters
x = r*np.cos(phase)
y = r*np.sin(phase)


config = json.dumps({"sensor_xpos":list(x), "sensor_ypos":list(y), "samplerate_hz":200, "duration_sec":1, "n_sensors":n_sensors}, indent=4)

 
with open("config.json", "w") as f:
    f.write(config)