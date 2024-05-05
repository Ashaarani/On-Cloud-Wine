# -*- coding: utf-8 -*-

import pandas as pd
import os
from sqlalchemy import create_engine


os.chdir("C:\\Users\\krall\\Documents\\OrderPort Sales Master")

# Read CSV file into DataFrame
shopkeep_file = "effingham_transaction_items_oneyeardata.xlsx"

shopkeep = pd.read_excel(shopkeep_file)

shopkeep['Time'] = pd.to_datetime(shopkeep['Time'])


def clean_currency(value):
    if isinstance(value, str):
        value = value.replace('$', '').replace(',', '').replace('(', '').replace(')', '').strip()
    return pd.to_numeric(value, errors='coerce')
transaction_items_oct = pd.read_excel('effingham_20231001-20231031-transaction-items.xlsx')
transaction_items_nov = pd.read_excel('effingham_20231101-20231130-transaction-items.xlsx')
transaction_items_dec = pd.read_excel('effingham_20231201-20231231-transaction-items.xlsx')
sales_by_customer_oct = pd.read_excel('effingham_sales_by_customer_from_2023-10-01_to_2023-10-31.xlsx')
sales_by_customer_nov = pd.read_excel('effingham_sales_by_customer_from_2023-11-01_to_2023-11-30.xlsx')
sales_by_customer_dec = pd.read_excel('effingham_sales_by_customer_from_2023-12-01_to_2023-12-31.xlsx')
club_members = pd.read_excel('Eff Members.xlsx')


# In[6]:


#for df in [sales_master_jan, sales_master_feb]:
 #   df['ProductExtPrice'] = df['ProductExtPrice'].apply(clean_currency)
  #  df['ProductDiscount'] = df['ProductDiscount'].apply(clean_currency)
   # df['SaleDate'] = pd.to_datetime(df['SaleDate'])
    #df['TotalNetRevenue'] = df['ProductExtPrice'] - df['ProductDiscount']

pc_wine_club_emails = club_members[club_members['Club Name'] == 'Effingham Wine Club']['Bill Email']

sales_by_customer_oct['Is PC Club Member'] = sales_by_customer_oct['Email'].isin(pc_wine_club_emails)
sales_by_customer_nov['Is PC Club Member'] = sales_by_customer_nov['Email'].isin(pc_wine_club_emails)
sales_by_customer_dec['Is PC Club Member'] = sales_by_customer_dec['Email'].isin(pc_wine_club_emails)

club_member_ids_oct = sales_by_customer_oct[sales_by_customer_oct['Is PC Club Member']]['Customer ID'].unique()
club_member_ids_nov = sales_by_customer_nov[sales_by_customer_nov['Is PC Club Member']]['Customer ID'].unique()
club_member_ids_dec = sales_by_customer_dec[sales_by_customer_dec['Is PC Club Member']]['Customer ID'].unique()

#sales_master_jan = sales_master_jan[sales_master_jan['CustomerClass'] == 'Effingham Wine Club']
#sales_master_feb = sales_master_feb[sales_master_feb['CustomerClass'] == 'Effingham Wine Club']

club_member_transactions_oct = transaction_items_oct[transaction_items_oct['Customer ID'].isin(club_member_ids_oct)]
club_member_transactions_nov = transaction_items_nov[transaction_items_nov['Customer ID'].isin(club_member_ids_nov)]
club_member_transactions_dec = transaction_items_dec[transaction_items_dec['Customer ID'].isin(club_member_ids_dec)]

club_member_transaction_shopkeep = pd.concat([club_member_transactions_oct, club_member_transactions_nov, club_member_transactions_dec], ignore_index=True)

club_member_transaction_shopkeep.rename(columns={
    'Time': 'SaleDate',
    'Line Item': 'ProductTitle',
    'Quantity': 'ProductQty',
    'Net Total': 'ProductExtPrice'
}, inplace=True)

club_member_transaction_shopkeep['ProductDiscount'] = 0
club_member_transaction_shopkeep['TotalNetRevenue'] = club_member_transaction_shopkeep['ProductExtPrice'] - club_member_transaction_shopkeep['ProductDiscount']
club_member_transaction_shopkeep['SaleDate'] = pd.to_datetime(club_member_transaction_shopkeep['SaleDate'])
club_member_transaction_shopkeep['Month'] = club_member_transaction_shopkeep['SaleDate'].dt.to_period('M').dt.strftime('%Y-%m')

combined_data = pd.concat([club_member_transaction_shopkeep], ignore_index=True)


# In[7]:


final_data = combined_data[['Month', 'SaleDate', 'ProductTitle', 'ProductQty', 'TotalNetRevenue']]

engine = create_engine('mssql+pyodbc://@LOLA\MSSQLSERVER2019/Capstone?trusted_connection=yes&driver=ODBC Driver 17 for SQL Server', echo = True)

final_data.to_sql('shopkeep_revenue_eff', con=engine, if_exists='replace', index=False)
shopkeep.to_sql('shopkeep_items_eff', con=engine, if_exists='replace', index=False)