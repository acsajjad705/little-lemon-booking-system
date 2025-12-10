import os
import mysql.connector
from dotenv import load_dotenv

load_dotenv()

def get_conn():
    return mysql.connector.connect(
        host=os.getenv("DB_HOST", "localhost"),
        user=os.getenv("DB_USER", "root"),
        password=os.getenv("DB_PASS", ""),
        database=os.getenv("DB_NAME", "little_lemon"),
    )

def call_proc(proc_name, args):
    conn = get_conn()
    cur = conn.cursor()
    cur.callproc(proc_name, args)
    results = []
    for result in cur.stored_results():
        results.append(result.fetchall())
    conn.commit()
    cur.close()
    conn.close()
    return results
