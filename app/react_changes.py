import time
from db_client import get_conn

def stream_audit(last_seen_id=0, interval=2):
    conn = get_conn()
    cur = conn.cursor(dictionary=True)
    try:
        while True:
            cur.execute(
                "SELECT * FROM BookingAudit WHERE AuditID > %s ORDER BY AuditID ASC",
                (last_seen_id,)
            )
            rows = cur.fetchall()
            for r in rows:
                last_seen_id = r["AuditID"]
                print(f"[{r['ChangedAt']}] Booking {r['BookingID']} action={r['Action']} {r['OldStatus']}->{r['NewStatus']}")
                # React: send email/push or sync cache
            time.sleep(interval)
    finally:
        cur.close()
        conn.close()

if __name__ == "__main__":
    # Start from latest known entry
    conn = get_conn()
    cur = conn.cursor()
    cur.execute("SELECT IFNULL(MAX(AuditID),0) FROM BookingAudit")
    start = cur.fetchone()[0]
    cur.close()
    conn.close()
    stream_audit(last_seen_id=start)
