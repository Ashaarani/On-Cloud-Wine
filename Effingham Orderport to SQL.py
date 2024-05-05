# -*- coding: utf-8 -*-

# In[65]:


import pandas as pd
from sqlalchemy import create_engine
from datetime import datetime
import os

os.chdir("C:\\Users\\krall\\Documents\\OrderPort Sales Master")


# In[66]:



# Read CSV file into DataFrame
csv_file_input = 'sales-master-feb24-eff.csv'

csv_file_dir = 'C:\\Users\\krall\\Documents\\OrderPort Sales Master'

df = pd.read_csv(csv_file_input)

#Transformation on the data
df['OrderDate'] = pd.to_datetime(df['OrderDate'])
df['SaleDate'] = pd.to_datetime(df['SaleDate'])

df['MembershipSince'] = pd.to_datetime(df['MembershipSince'])
df['OrderFutureShipDate'] = pd.to_datetime(df['OrderFutureShipDate'])
df['BirthDate'] = pd.to_datetime(df['BirthDate'])
df['BirthDate'] = df['BirthDate'].dt.strftime('%Y-%m-%d')
df['UploadTimestamp'] = pd.Timestamp(datetime.now())

# Handle 'ReleaseDate' column
def parse_release_date(value):
    if value == "not yet released":
        return pd.NaT  # Return NaT for the specific case
    else:
        try:
            return pd.to_datetime(value)  # Convert other values to datetime
        except ValueError:
            return pd.NaT  # Return NaT if parsing fails

df['ReleaseDate'] = df['ReleaseDate'].apply(parse_release_date)
df['OrderPaymentStatus'] = df['OrderPaymentStatus'].str.slice(0,99)
df['OrderedItems'] = df['OrderedItems'].str.slice(0, 254)
df['AccountNotes'] = df['AccountNotes'].str.slice(0, 99)

df = df.applymap(lambda x: x.replace('$', '') if isinstance(x, str) else x)
df = df.applymap(lambda x: x.replace(',', '') if isinstance (x,str) else x)
df = df.applymap(lambda x:x.replace('(', '-') if isinstance (x, str) else x)
df = df.applymap(lambda x:x.replace(')', '') if isinstance (x, str) else x)
df = df.fillna(0)


# In[24]:


def process_campaign_data(campaign_name, sent_file, opened_file, clicked_file):

    sent_df = pd.read_csv(sent_file)
    opened_df = pd.read_csv(opened_file)
    clicked_df = pd.read_csv(clicked_file)

    
    opened_df['Opened'] = opened_df['Opened At'].notnull().astype(int)
    clicked_df['Clicked'] = clicked_df['Clicked At'].notnull().astype(int)
    
    opened_minimal = opened_df[['Email address', 'Opened']].drop_duplicates()
    clicked_minimal = clicked_df[['Email address', 'Clicked']].drop_duplicates()
    
    merged_df = sent_df.merge(opened_minimal, on='Email address', how='left')\
                       .merge(clicked_minimal, on='Email address', how='left').fillna(0)
    
    merged_df['Campaign Name'] = campaign_name
    merged_df['Month'] = pd.to_datetime(merged_df['Sent At']).dt.month_name()
    merged_df['Sent At'] = pd.to_datetime(merged_df['Sent At'])
    merged_df = merged_df.drop('notes', axis =1)
    
    merged_df['Customer Type'] = pd.to_datetime(merged_df['Sent At']) - pd.to_datetime(merged_df['Created At'].str.split(' ').str[0])
    merged_df['Customer Type'] = merged_df['Customer Type'].dt.days.apply(lambda x: 'New Customer' if x <= 30 else 'Old Customer')
    
    return merged_df



# In[3]:


campaign_files = [
    {
        'name': '02.05.24',
        'opened': "contact_export_Effingham Opened.csv",
        'sent': 'contact_export_Effingham Sent.csv',
        'clicked': 'contact_export_Effingham Clicked.csv'
    }
] 


# In[4]:


all_campaigns_data = pd.DataFrame()
for campaign in campaign_files:
    campaign_data = process_campaign_data(
        campaign_name=campaign['name'],
        sent_file=campaign['sent'],
        opened_file=campaign['opened'],
        clicked_file=campaign['clicked']
    )
    all_campaigns_data = pd.concat([all_campaigns_data, campaign_data], ignore_index=True)





wine_clubmember_sales_data = df[df['CustomerClass'] == 'PC Wine Club']

wine_clubmember_sales_data_Unique=wine_clubmember_sales_data.drop_duplicates(subset=['OrderNumber'])

df = wine_clubmember_sales_data_Unique[['BillLastName', 'BillFirstName', 'AccountCreationDate', 'OrderDate','CustomerNumber','BillEmail']]



# In[ ]:



member_startdates_actual = pd.read_excel('WineClubStartDatesEffingham.xlsx')
member_startdates_actual.drop_duplicates(subset=['BillLastName','BillFirstName'])




df_merged = pd.merge(df,member_startdates_actual,
                     on=['BillLastName', 'BillFirstName'],
                     how='left')

df_merged['actual_account_creation_date'] = df_merged['AccountCreationDate_y'].fillna(df_merged['AccountCreationDate_x'])





df_merged['actual_account_creation_date'] = pd.to_datetime(df_merged['actual_account_creation_date'],format='%Y-%m-%d %H:%M:%S', errors='coerce')

df_merged['OrderDate'] = pd.to_datetime(df_merged['OrderDate'])


# In[60]:

engine = create_engine('mssql+pyodbc://@LOLA\MSSQLSERVER2019/Capstone?trusted_connection=yes&driver=ODBC Driver 17 for SQL Server', echo = True)

df.to_sql('orderport_eff', con=engine, if_exists='replace', index=False)
all_campaigns_data.to_sql('campaigns_eff', con=engine, if_exists='replace', index=False)
df_merged.to_sql('visits_eff', con=engine, if_exists='replace', index=False)


