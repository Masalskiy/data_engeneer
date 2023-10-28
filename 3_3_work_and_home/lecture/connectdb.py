import psycopg2

host = 'localhost'
port = '5432'
username = ''
password = ''
database = ''

# установка подключения
connection = psycopg2.connect(
    host=host,
    port=port,
    user=username,
    password=password,
    database=database
)

# Создание объекта "курсор"
cursor = connection.cursor()

query = "SELECT * FROM table_name"

# выполнение запроса
cursor.execute(query=query)

# Получение результатов
#важно смотреть типы данных
results = cursor.fetchall()
# fetchone()

# Вывод результатов
for row in results:
    print(row)

# Закрытие курсора
cursor.close()

# Закрытие подключения
connection.close()


# Транзакции
cursor = connection.cursor()

try:
    # Начало транзакции
    connection.begin()

    # Выполнение запросов
    cursor.execute("INSERT INTO table_name (column) VALUES ('value')")
    cursor.execute("UPDATE table_name SET column = 'new_value")

    # Закоммитить изменения
    connection.commit()

except Exception as e:
    # Ошибка или откат изменений
    connection.rollback()
    print("Error: ", e)

finally:
    # Закрытие курсора
    cursor.close()

    # Закрытие подключения
    connection.close()


# Множественная вставка
# создание объекта курсора
cursor = connection.cursor()


# множественная вставка данных
data = [
    ('John', 30),
    ('Alice', 30),
    ('Bob', 28)
]
query = "INSERT INTO table_name (name, age) VALUES (%s, %s)"
cursor.executemany(query, data)

connection.commit()
cursor.close()
connection.close()