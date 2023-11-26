import pandas as pd
import numpy as np
import json

alphawave = np.loadtxt("alphawave.csv")
sensors = np.loadtxt("sensor_background_noise.csv", delimiter=",")
with open("config.json") as f:
    config = json.load(f)

sensor_data = {}
for i in range(config["n_sensors"]):
    sensor_data[f"sensor_noise_{i}"] = sensors[:,i]
    sensor_data[f"sensor_{i}"] = sensors[:,i]+alphawave
sensor_data["original_signal"] = alphawave
df = pd.DataFrame(sensor_data)
df.to_csv("sensor_data.csv", index=False)


