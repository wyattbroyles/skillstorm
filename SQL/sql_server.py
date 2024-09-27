import pymssql

conn = pymssql.connect(server='WY_PC')

# create a cursor to run queries

cursor = conn.cursor()
cursor.execute('SELECT * FROM INFORMATION_SCHEMA.TABLES')
rows = cursor.fetchall()
[print(row) for row in rows]