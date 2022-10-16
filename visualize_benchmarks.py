import matplotlib.pyplot as plt
import pandas as pd
import numpy as np

benchmarks_pd = pd.read_csv('benchmarks.csv', sep=';')

time_col = 'Elapsed Time'
iters_without_err_col = 'Iters without err counting'

def plot_benchmarks_by_target(target_device: str):
    vers_device = [benchmarks_pd[(benchmarks_pd['Target device'] == target_device) & 
                              (benchmarks_pd['Algo ver'] == f'Version {i}')][[time_col, iters_without_err_col]]
                for i in range(1, 5)]

    fig, ax = plt.subplots(figsize=(18, 9))

    log_iters = np.log(vers_device[2][iters_without_err_col])
    labels_iters = vers_device[2][iters_without_err_col]

    ax.axhline(vers_device[1][time_col].values[0], color='r', label='Version 2')
    ax.plot(log_iters, vers_device[2][time_col], label='Version 3')
    ax.plot(log_iters, vers_device[3][time_col], label='Version 4')

    ax.set_xticks(log_iters)
    ax.set_xticklabels(labels_iters, rotation=45)
    ax.set_ylabel('Elapsed time, seconds')
    ax.set_xlabel('Number of iters without err')
    ax.set_title(target_device)
    ax.legend()
    fig.savefig(f'benchmarks_{target_device}.png')

plot_benchmarks_by_target('CPU')
plot_benchmarks_by_target('GPU')
