import mysql.connector
from db_client import get_conn

def select(query, params=None):
    conn = get_conn()
    cur = conn.cursor(dictionary=True)
    cur.execute(query, params or ())
    rows = cur.fetchall()
    cur.close()
    conn.close()
    return rows

def call_add_booking(customer_id, table_id, date_str, time_str, guests, notes):
    conn = get_conn()
    cur = conn.cursor()
    cur.execute("SET @id := NULL;")
    cur.execute("SET @msg := '';")
    cur.callproc("AddBooking", [customer_id, table_id, date_str, time_str, guests, notes, 0, ""])
    # OUT params via user variables are not auto-populated; select messages for demo instead:
    # Use a final SELECT inside procedure for clean retrieval if preferred.
    cur.close()
    conn.close()

def demo():
    # Get max quantity
    conn = get_conn()
    cur = conn.cursor()
    cur.execute("SET @max := 0;")
    cur.callproc("GetMaxQuantity", [0])
    cur.execute("SELECT @max;")
    print("MaxQuantity:", cur.fetchone())
    cur.close()
    conn.close()

    # Show booking overview view
    rows = select("SELECT * FROM vw_booking_overview ORDER BY BookingDate, BookingTime LIMIT 10;")
    for r in rows:
        print(r)

if __name__ == "__main__":
    demo()
