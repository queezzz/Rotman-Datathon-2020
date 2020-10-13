import pandas as pd
import pandas_profiling

##beneficiary
pd.read_csv('../Datathon2020data/beneficiary.csv').profile_report(title='beneficiary_EDA').to_file(output_file='beneficiary_EDA.html')

##inpatients
pd.read_csv('../Datathon2020data/inpatients.csv').profile_report(title='inpatients_EDA').to_file(output_file='inpatients_EDA.html')


##outpatients
pd.read_csv('../Datathon2020data/outpatients.csv').profile_report(title='outpatients_EDA').to_file(output_file='outpatients_EDA.html')


##providers
pd.read_csv('../Datathon2020data/providers.csv').profile_report(title='providers_EDA').to_file(output_file='providers_EDA.html')

