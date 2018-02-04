# Information

1. Raw data obtained from
http://www.nemweb.com.au/REPORTS/ARCHIVE/Dispatch_SCADA/

These files contains actual generation data for each scheduled generation unit, semi-scheduled generation unit, and non-scheduled generating units or non-scheduled generating systems (a non-scheduled generating system comprising non-scheduled generating units).

2. Two files:
i. wind_data_sa.csv: CSV format file of 5 minute intervals of MW readings, starting 26/01/2015 00:10:00 from 17 windfarms around SA, and
ii. combustion_data_sa.csv: CSV format file of 5 minute intervals of MW readings, starting 26/01/2015 00:10:00 from 32 combustion units (coal, gas, diesel).

3. wind_data_sa.csv: Header format
Column 1: DATE - yyyy/mm/dd hh:mm:ss
The rest of the columns are the 17 windfarms arranged in alphabetical order

4. combustion_data_sa.csv: Header format
Column 1: DATE - yyyy/mm/dd hh:mm:ss
The rest of the columns are the 32 combustion generation units arranged in alphabetical order

5. Timezones: all AEMO data is standardised on Eastern Standard Time (EST).


# ISSUES
## wind_data_sa.csv

1. What does negative generation mean?
2. Missing information
i. Quite a bit missing from CNUNDAWF (Canunda) and STARTHLWF (Starfish Hill), e.g., rows 10245 to 10261 02/03/2015 13:45 to 15:05
ii. Some missing bits from BLUFF1 (The Bluff), e.g., rows 11378 to 11384 06/03/2015 12:10 to 12:40
iii. Some missing data from MTMLLAR (Mount Millar), e.g., rows 105217 to 105218 27/01/2016 8:05 to 8:10
iv. Occasional missing data rows from several windfarms CATHROCK (Cathedral Rock), CNUNDAWF (Canunda), LKBONNY1 (Lake Bonny 1), MTMILLAR (Mount Millar), STARHLWF (Starfish Hill), WPWF (Wattle Point), e.g., row 112159 20/02/2016 10:35 
v. Counts of missing data (total current number of entries: 131328)
CATHROCK 	101	0.077%
CNUNDAWF 	606	0.461%
LKBONNY1 	182	0.139%
MTMILLAR 	90	0.069%
STARHLWF 	513	0.391%
WPWF 		48	0.037%

3. Duplicates
i. Some raw data files repeat information from some windfarms.
4. Note that Snowtown Stage 2 consists of two separately metered wind
farms: Snowtown Stage 2 North (SNOWNTH1) and Snowtown Stage 2 South
(SNOWSTH1)


## combustion_data_sa.csv

1. Missing data
i. 27/01/2015 5:10 to 5:15, 17:50 to 17:55, 16/04/2015 6:00 to 6:05 etc. ANGAS1 and ANGAS2
ii. PTSTAN1 (Port Stanvac) data available from row 100801 12/01/2016 0:05 onwards
iii. Counts of missing data
ANGAS1		1253	1.059%
ANGAS2		1278	1.080%
PTSTAN1		100799	85.157%

2. Negative generation for ANGAS1 (Angaston 1) and ANGAS2 (Angaston 2).
3. Includes Playford B (PLAYB.AG) but this powerplant has been mothballed since 2012. In file, all entries are 0.
4. Northern powerplant: full retirement in March 2016.

# COMPARISON WITH PRICE

1. Seems that AGL controlled power stations come online approximately 5 minutes before high spot prices or at the time of settlement. These are during times when the neighboring prices are low.

Examples:
1. 13/01/2015 10:30 Demand: 1873.1 MWh, Price: $4342.64, Online: AGLHAL
2. 11/11/2015 13:30 Demand: 1370.45 MWh, Price: $2388.72, Online: AGLHAL, ANGAS1, ANGAS2 
3. 12/11/2015 9:00 Demand: 1343.14 MWh, Price: $2291.49, Online: AGLHAL, ANGAS1, ANGAS2 

# INTERPOLATION

1. Missing data in the wind combustion data was filled using linear interpolation via pandas.
i. wind_data_sa_interpolated.csv: interpolated SA wind generation data
ii. combustion_data_sa_interpolated.csv: interpolated SA combustion generation data

# PRINCIPAL COMPONENTS

1. First two principal components group the windfarms coinciding with the
AEMO classification:
i. SOUTHERN: LKBONNY1, LKBONNY2, LKBONNY3, CNUNDAWF
ii. COASTAL PENINSULA: CATHROCK, STARHLWF, WPWF
iii. MIDNORTH: the rest
(see figures "wind_farm_pca_split.pdf" and "basic_pca_wind_farm.eps")
2. Principal Components Percentage per component (cumulative sum)
56.40576  72.11398  79.53977  84.25250  87.62100  90.65287  92.39952  93.91590  95.31717  96.50729  97.55076  98.17699  98.68408  99.13016  99.47048  99.76490 100.00000
This shows that the first 6 components explain 90.7% of the variation.
