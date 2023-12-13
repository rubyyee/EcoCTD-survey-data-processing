Some code to read in and process a .rsk file from the EcoCTD, for a given survey and sensor configuration.

Individual parameters must be specified manually for each survey in setup_params_by_date. As an example, 2023-05 is set to run (the .rsk and .gpx files are provided in the example_data directory). In order to read and process other surveys, the parameters 'filename' and 'gps_path' must be specified in setup_params_by_date.

All data processing happens in read_and_process_rsk.