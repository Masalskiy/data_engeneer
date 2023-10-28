#-*- coding: UTF-8 -*-
import requests
import psycopg2 as ps2
import psycopg2.extras as extras
import json
from datetime import datetime
import calendar
from sys import argv
from configparser import ConfigParser
import pandas as pd
import numpy as np 

access_key = ''
live_cur = 'http://api.exchangerate.host/live'
hist_url = 'http://api.exchangerate.host/historical'

pg_hostname = ''
pg_port = ''
pg_username = ''
pg_pass = ''
pg_db = ''


data_json = {'success': True,
             'terms': 'https://currencylayer.com/terms', 
             'privacy': 'https://currencylayer.com/privacy', 
             'timestamp': 1698249183, 
             'source': 'BTC', 
             'quotes': {'BTCRUB': 3248800.569448}}

def main():
    init_credentals()
    print(argv)
    if argv[1] == 'l':
        get_latest_rate(argv[2], argv[3])
    elif argv[1] == 'c':
        get_rate_in_month(int(argv[2]), int(argv[3]), argv[4], argv[5])
    elif argv[1] == 'a':
        data = get_exch_rate_by_interval(argv[2], argv[3], argv[4], argv[5])
        print("Сводные данные по курсу обмена: ")
        save_statistic_into_bd(analyse_exchange_rate(data))
    else:
        print('Смотри документацию')

  

def init_credentals():
    urlsconf = 'config/config.ini'
    config = ConfigParser() 
    config.read(urlsconf)
    global access_key
    access_key = config['excange_api']['access_key']
    global pg_hostname 
    global pg_port
    global pg_username
    global pg_pass
    global pg_db
    pg_hostname = config['login_db']['pg_hostname']
    pg_port = config['login_db']['pg_port']
    pg_username = config['login_db']['pg_username']
    pg_pass = config['login_db']['pg_pass']
    pg_db = config['login_db']['pg_db']

def convert_map_to_json(data_json):
    jsn = json.dumps(data_json)
    return json.loads(jsn)

def get_latest_rate(from_curr, to_curr):
    try:
        response = requests.get(live_cur, params={'access_key': access_key,
                                                      'currencies': to_curr,
                                                      'source': from_curr})
    except Exception as err:
        print(f'Error occured: {err}')
        return
    
    if response.status_code == 200:
        data = response.json()
        print(data)
        if 'error' in data:
            print(data['error'])
            return
        insert_data(data)
    else:
        print(response.status_code)

def get_rate_in_month(year, month, from_curr, to_curr):
    weekday, nums_day = calendar.monthrange(year, month)
    if month<10:
        month = f"0{month}"
    for day in range(1, nums_day+1):
        print(day)
        if day < 10:
            day= f"0{day}"
        date = f"{year}-{month}-{day}"

        try:
            response = requests.get(hist_url, params={'access_key': access_key,
                                                      'currencies': to_curr,
                                                      'source': from_curr,
                                                      'date': date})
        except Exception as err:
            print(f'Error occured: {err}')
            return
        
        if response.status_code == 200:
            data = response.json()
            print(data)
            if 'error' in data:
                print(f"Причина ошибки: {data['error']}")  
                return 
            insert_data(data)
        else:
            print(response.status_code)
            return

# сохранить курс в БД
def insert_data(data):
    date = datetime.utcfromtimestamp(data['timestamp']).strftime('%Y-%m-%d %H:%M:%S')

    connection = ps2.connect(
        host=pg_hostname,
        port=pg_port,
        user=pg_username,
        password=pg_pass,
        database=pg_db
    )

    try:
        cursor = connection.cursor()
        for cur in data['quotes']:
            from_curr = cur[0:3] 
            to_curr = cur[3:]
            rate = data['quotes'].get(cur)

            insert_query = f"""INSERT INTO rates(date, from_curr, to_curr, rate) VALUES 
                        {date, from_curr, to_curr, rate}"""
            cursor.execute(query=insert_query)
        connection.commit()
    except Exception as e:
        # Ошибка или откат изменений
        connection.rollback()
        print("Error: ", e)
    finally:
        cursor.close()
        connection.close()

def get_exch_rate_by_interval(from_curr, to_curr, date_from, date_to):
    connection = ps2.connect(
        host=pg_hostname,
        port=pg_port,
        user=pg_username,
        password=pg_pass,
        database=pg_db
    )

    try:
        cursor = connection.cursor()
        get_query = f"""select r.id, r.date, c.curr from_curr, c2.curr to_curr, r.rate  from rate r 
                            left join currency c on r.from_curr = c.id_cur 
                            left join currency c2 on r.to_curr = c2.id_cur
                            where date BETWEEN '{date_from}' AND '{date_to}'
                                and c.curr='{from_curr}' and c2.curr='{to_curr}'"""

        cursor.execute(query=get_query)
        results = cursor.fetchall()
        return results
    except Exception as e:
        # Ошибка или откат изменений
        connection.rollback()
        print("Error: ", e)
    finally:
        cursor.close()
        connection.close()
    

def analyse_exchange_rate(data):
    df = pd.DataFrame(data, columns=['id', 'date', 'from_curr', 'to_curr', 'rate'])
    df = df.drop_duplicates()
    # Изменение курса
    df['lead'] = df['rate'].shift(1)
    df['rate_diff'] = df['rate'] - df['lead']
    df = df.drop('lead', axis = 1).fillna(0)
    # добавляю стобец для группировки year_month
    df['year_month'] = df['date'].dt.to_period("M")
    df['year_month_date'] = df['date'].dt.to_period("D")
    # начало заполнения стат данных
    # минимальное значение курса
    # максимальное значение курса
    df_stats = df.groupby(by=['year_month', 'from_curr', 'to_curr'], as_index=False).agg(max_curr_rate = ('rate', 'max'),
                                                                                   min_curr_rate = ('rate', 'min'))
    # день, в который значение курса было максимальным
    df_stats = df_stats.merge(df,
                   left_on=['year_month', 'from_curr', 'to_curr', 'max_curr_rate'], 
                   right_on=['year_month', 'from_curr', 'to_curr', 'rate'],
                   how = 'left'
                   
                   )[['year_month', 'from_curr', 'to_curr', 'max_curr_rate', 'date', 'min_curr_rate']].rename(columns={'date': 'max_curr_date'})
    # день, в который значение курса было минимальным
    df_stats['min_curr_date'] = df_stats.merge(df,
                   left_on=['year_month', 'from_curr', 'to_curr', 'min_curr_rate'], 
                   right_on=['year_month', 'from_curr', 'to_curr', 'rate'],
                   how = 'left'
                   )[['date']].rename(columns={'date': 'min_curr_date'})
    # среднее значение курса за весь месяц
    avg_curr_by_month = df.groupby(by=['year_month', 'from_curr', 'to_curr'], as_index=False).agg(avg_rate_month = ('rate', 'mean'))
    df_stats['avg_rate_month'] = df_stats.merge(avg_curr_by_month,
                              left_on=['year_month', 'from_curr', 'to_curr'],
                              right_on=['year_month', 'from_curr', 'to_curr'],
                              how = 'left'
                             )[['avg_rate_month']]

    # Собираю все разные месяцы
    all_month = df['year_month'].unique()
    # узнаю их последний день
    get_last_day = [pd.Period(str(year_month) +'-'+ str(year_month.daysinmonth)) for year_month in all_month]
    # фрейм с последними курсами на конец месяца
    rows_last_day = df[df.year_month_date.isin(get_last_day)]
    # значение курса на последний день месяца
    df_stats[['last_rate_in_month', 'last_date_in_month']] = df_stats.merge(rows_last_day,
                   left_on=['year_month', 'from_curr', 'to_curr'],
                   right_on=['year_month', 'from_curr', 'to_curr'],
                   how = 'left'
    )[['rate', 'date']].rename(columns={'rate': 'last_rate_in_month', 'date': 'last_date_in_month'})
    df_stats['year_month'] = df_stats['year_month'].astype({'year_month': 'string'})
    df_stats['last_date_in_month'] = df_stats['last_date_in_month'].fillna(np.datetime64(1, 'Y'))
    df_stats['last_rate_in_month'] = df_stats['last_rate_in_month'].fillna(-1)
    print('analyse_exchange_rate')
    print(df_stats)
    return df_stats

def save_statistic_into_bd(df):
    # conn_string = 'postgres://postgres:pass@127.0.0.1/rates'
    # db = create_engine(conn_string)
    # conn = db.connect() 
    table = 'statistic_rate'
    connection = ps2.connect(
        host=pg_hostname,
        port=pg_port,
        user=pg_username,
        password=pg_pass,
        database=pg_db
    )
    # чтобы итерироваться по списку кортежей и записывать по одной строке
    # пришлось сделать список списков кортежей
    tuples = [[tuple(x)] for x in df.to_numpy()] 
    
    cols = ','.join(list(df.columns)) 
    query = "INSERT INTO %s(%s) VALUES %%s" % (table, cols) 
    try:
        cursor = connection.cursor()
        for tup in tuples:
            try:
                extras.execute_values(cursor, query, tup)
                connection.commit()
            except Exception as e:
                # Ошибка или откат изменений
                connection.rollback()
                print("Error: ", e)
    finally:
        cursor.close()
        connection.close()
    

if __name__ == "__main__":
    main()
