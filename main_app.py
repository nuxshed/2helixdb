import pymysql
import sys
from getpass import getpass

# --- TERMINAL COLORS ---
class C:
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    END = '\033[0m'
    BOLD = '\033[1m'

# --- CONFIGURATION ---
DB_CONFIG = {
    'host': 'localhost',
    'database': 'mini_world_db',
    'cursorclass': pymysql.cursors.DictCursor,
    'autocommit': True
}

# --- SECURITY CONFIGURATION ---
# Maps Table Name -> Minimum Security Clearance Required
REQUIRED_CLEARANCE = {
    # Level 1-4: Basic Operations
    'ASSET': 1, 'ASSET_TRANSACTION': 1, 'ASSET_SEIZURE': 1, 
    'TRAVEL_LOG': 1, 'CITIZEN': 1, 'DEPENDENT': 1,
    
    # Level 6: Visa Control
    'VISA': 6,
    
    # Level 7: Judicial
    'CRIMINAL_SENTENCING': 7,
    
    # Level 8: Infrastructure
    'PLANET': 8, 'SECTOR': 8, 'STATION': 8, 'GOVERNINGOFFICE': 8,
    
    # Level 9: Legislative & Admin
    'ETHNICITY': 9, 'LAW': 9, 'LAW_APPLICABILITY': 9, 'OFFICIAL': 9
}

def get_connection():
    print(f"{C.CYAN}Connecting to Mini World Database...{C.END}")
    user = input("User (root): ").strip() or 'root'
    password = getpass("Password: ")
    try:
        return pymysql.connect(user=user, password=password, **DB_CONFIG)
    except pymysql.Error as e:
        print(f"{C.FAIL}[ERROR] Connection failed: {e}{C.END}")
        sys.exit(1)

# --- UI COMPONENTS ---

def print_header(text):
    print(f"\n{C.BOLD}{C.CYAN}=== {text.upper()} ==={C.END}")

def print_table(title, data):
    if not data:
        print(f"\n{C.WARNING}[ {title} ] - No records found.{C.END}")
        return

    headers = list(data[0].keys())
    widths = [max(len(str(row[h])) for row in data + [{h: h}]) + 2 for h in headers]
    
    print(f"\n{C.HEADER}>>> {title} <<<{C.END}")
    header_row = "".join(h.ljust(w) for h, w in zip(headers, widths))
    print(f"{C.BOLD}{header_row}{C.END}")
    print(f"{C.BLUE}" + "-" * len(header_row) + f"{C.END}")
    
    for row in data:
        print("".join(str(row[h]).ljust(w) for h, w in zip(headers, widths)))
    print("")

def draw_id_card(citizen):
    w = 50 
    c_name = f"{citizen['FirstName']} {citizen['LastName']}"
    c_id = str(citizen['CitizenID'])
    c_home = citizen.get('StationName', 'Unknown')
    c_eth = citizen.get('Ethnicity', 'Unknown')
    c_dob = str(citizen['DateOfBirth'])

    def print_row(label, val):
        content_len = len(label) + 1 + len(val)
        padding = " " * (w - 4 - content_len) 
        print(f"| {C.BOLD}{label}{C.END} {val}{padding} {C.CYAN}|")

    print(f"\n{C.CYAN}" + "+" + "-" * (w - 2) + "+")
    print(f"|{C.BOLD}{'GALACTIC CITIZEN IDENTIFICATION':^{w-2}}{C.END}{C.CYAN}|")
    print("+" + "-" * (w - 2) + "+")
    print_row("NAME :", c_name)
    print_row("ID   :", c_id)
    print_row("ORIG :", c_home)
    print_row("SPEC :", c_eth)
    print_row("DOB  :", c_dob)
    print("+" + "-" * (w - 2) + f"+{C.END}\n")

# --- DATA ACCESS (CITIZEN) ---

def get_citizen_details(conn, cid):
    with conn.cursor() as cur:
        sql = """
            SELECT C.CitizenID, C.FirstName, C.LastName, C.DateOfBirth, 
                   S.StationName, E.Name as Ethnicity, C.EthnicityID
            FROM CITIZEN C
            LEFT JOIN STATION S ON C.HomeStationID = S.StationID
            LEFT JOIN ETHNICITY E ON C.EthnicityID = E.EthnicityID
            WHERE C.CitizenID = %s
        """
        cur.execute(sql, (cid,))
        return cur.fetchone()

def view_assets(conn, cid):
    with conn.cursor() as cur:
        sql = """
            SELECT T.TransactionID, A.AssetType, CONCAT('$', FORMAT(T.Value, 2)) as Cost 
            FROM ASSET_TRANSACTION T
            JOIN ASSET A ON T.AssetID = A.AssetID
            WHERE T.BuyerCitizenID = %s
        """
        cur.execute(sql, (cid,))
        print_table("Acquired Assets", cur.fetchall())

def view_visas(conn, cid):
    with conn.cursor() as cur:
        sql = """
            SELECT V.VisaID, S.StationName as Destination, V.Status, V.ExpiryDate 
            FROM VISA V 
            JOIN STATION S ON V.DestID = S.StationID 
            WHERE V.CitizenID = %s
        """
        cur.execute(sql, (cid,))
        print_table("Visa Status", cur.fetchall())

def view_transactions(conn, cid):
    with conn.cursor() as cur:
        sql = """
            SELECT TransactionID, CONCAT('$', FORMAT(Value, 2)) as Amount, 
            CASE WHEN BuyerCitizenID = %s THEN 'BOUGHT' ELSE 'SOLD' END as Type,
            SellerCitizenID as Counterparty
            FROM ASSET_TRANSACTION 
            WHERE BuyerCitizenID = %s OR SellerCitizenID = %s
        """
        cur.execute(sql, (cid, cid, cid))
        print_table("Transaction History", cur.fetchall())

def view_public_data(conn, profile=None):
    while True:
        print(f"\n{C.HEADER}╔════ PUBLIC RECORDS DIRECTORY ════╗{C.END}")
        print(f"{C.CYAN}║ 1. [SEC] Galactic Sectors        ║")
        print(f"║ 2. [SYS] Planetary Systems       ║")
        print(f"║ 3. [STN] Space Stations          ║")
        print(f"║ 4. [LAW] Galactic Law Database   ║")
        print(f"║ b. Back                          ║{C.END}")
        print(f"{C.HEADER}╚══════════════════════════════════╝{C.END}")
        
        ch = input(f"\n{C.CYAN}Access Query > {C.END}").strip().lower()
        
        with conn.cursor() as cur:
            if ch == '1':
                cur.execute("SELECT SectorName, StellarCentralCoordinates FROM SECTOR")
                print_table("Galactic Sectors", cur.fetchall())
            elif ch == '2':
                sql = """SELECT P.PlanetName, P.StellarCoordinates, S.SectorName as 'Parent Sector'
                         FROM PLANET P JOIN SECTOR S ON P.SectorID = S.SectorID"""
                cur.execute(sql)
                print_table("Planetary System", cur.fetchall())
            elif ch == '3':
                sql = """SELECT S.StationName, S.GeographicCoordinates, P.PlanetName as 'Parent Planet'
                         FROM STATION S JOIN PLANET P ON S.PlanetID = P.PlanetID"""
                cur.execute(sql)
                print_table("Space Stations", cur.fetchall())
            elif ch == '4':
                if profile:
                    print(f"{C.GREEN}Filtering laws applicable to: {profile['Ethnicity']}...{C.END}")
                    sql = """SELECT DISTINCT L.Title, L.IssuingOfficeID FROM LAW L
                             LEFT JOIN LAW_APPLICABILITY LA ON L.LawID = LA.LawID
                             WHERE LA.EthnicityID = %s OR LA.LawID IS NULL"""
                    cur.execute(sql, (profile['EthnicityID'],))
                else:
                    cur.execute("SELECT Title, IssuingOfficeID FROM LAW")
                print_table("Galactic Laws", cur.fetchall())
            elif ch == 'b':
                break

# --- OFFICIAL MODE LOGIC ---

def get_official_profile(conn, cid):
    with conn.cursor() as cur:
        sql = """SELECT O.CitizenID, O.RankTitle, O.SecurityClearance, 
                 C.FirstName, C.LastName FROM OFFICIAL O
                 JOIN CITIZEN C ON O.CitizenID = C.CitizenID WHERE O.CitizenID = %s"""
        cur.execute(sql, (cid,))
        return cur.fetchone()

def get_table_schema(conn, table):
    """Fetches column info for dynamic CRUD."""
    with conn.cursor() as cur:
        cur.execute(f"DESCRIBE {table}")
        return cur.fetchall()

def crud_insert(conn, table):
    print(f"\n{C.HEADER}--- INSERT INTO {table} ---{C.END}")
    schema = get_table_schema(conn, table)
    vals, cols = [], []
    
    try:
        for col in schema:
            if 'auto_increment' in col['Extra']: continue
            val = input(f"{col['Field']} ({col['Type']}): ").strip()
            vals.append(val if val else None)
            cols.append(col['Field'])
            
        placeholders = ', '.join(['%s'] * len(vals))
        sql = f"INSERT INTO {table} ({', '.join(cols)}) VALUES ({placeholders})"
        
        with conn.cursor() as cur:
            cur.execute(sql, tuple(vals))
        print(f"{C.GREEN}Record inserted.{C.END}")
    except Exception as e:
        print(f"{C.FAIL}Error: {e}{C.END}")

def crud_update(conn, table):
    print(f"\n{C.HEADER}--- UPDATE {table} ---{C.END}")
    schema = get_table_schema(conn, table)
    pk_col = next((c['Field'] for c in schema if c['Key'] == 'PRI'), None)
    
    if not pk_col:
        print(f"{C.FAIL}No Primary Key found. Cannot update.{C.END}"); return

    pk_val = input(f"Enter {pk_col} of record to update: ").strip()
    field = input(f"Field to update ({', '.join(c['Field'] for c in schema)}): ").strip()
    new_val = input(f"New value for {field}: ").strip()
    
    try:
        sql = f"UPDATE {table} SET {field} = %s WHERE {pk_col} = %s"
        with conn.cursor() as cur:
            cur.execute(sql, (new_val if new_val else None, pk_val))
        print(f"{C.GREEN}Record updated.{C.END}")
    except Exception as e:
        print(f"{C.FAIL}Error: {e}{C.END}")

def crud_delete(conn, table):
    print(f"\n{C.HEADER}--- DELETE FROM {table} ---{C.END}")
    schema = get_table_schema(conn, table)
    pk_col = next((c['Field'] for c in schema if c['Key'] == 'PRI'), None)
    
    if not pk_col: print(f"{C.FAIL}No PK found.{C.END}"); return

    pk_val = input(f"Enter {pk_col} to delete: ").strip()
    if input(f"{C.WARNING}Confirm deletion? (y/n): {C.END}").lower() == 'y':
        try:
            with conn.cursor() as cur:
                cur.execute(f"DELETE FROM {table} WHERE {pk_col} = %s", (pk_val,))
            print(f"{C.GREEN}Record deleted.{C.END}")
        except Exception as e:
            print(f"{C.FAIL}Error: {e}{C.END}")

def manage_table(conn, table):
    while True:
        print(f"\n{C.BOLD}:: MANAGING {table} ::{C.END}")
        print("1. View | 2. Insert | 3. Update | 4. Delete | b. Back")
        ch = input(f"{C.CYAN}Op > {C.END}").strip()
        
        if ch == '1':
            with conn.cursor() as cur:
                cur.execute(f"SELECT * FROM {table} LIMIT 50")
                print_table(table, cur.fetchall())
        elif ch == '2': crud_insert(conn, table)
        elif ch == '3': crud_update(conn, table)
        elif ch == '4': crud_delete(conn, table)
        elif ch == 'b': break

def official_dashboard(conn, profile):
    lvl = profile['SecurityClearance']
    while True:
        print(f"\n{C.HEADER}OFFICIAL TERMINAL [LEVEL {lvl}]{C.END}")
        # Filter tables by permission level
        tables = sorted([t for t, l in REQUIRED_CLEARANCE.items() if lvl >= l])
        
        for i, t in enumerate(tables):
            print(f"{i+1:2}. {t}")
        print(" q. Logout")
        
        ch = input(f"\n{C.CYAN}Select Table > {C.END}").strip()
        if ch == 'q': break
        if ch.isdigit() and 1 <= int(ch) <= len(tables):
            manage_table(conn, tables[int(ch)-1])
        else:
            print(f"{C.WARNING}Invalid.{C.END}")

def official_mode(conn):
    try:
        cid = input(f"\n{C.CYAN}Enter Official ID: {C.END}").strip()
        profile = get_official_profile(conn, cid)
        if not profile:
            print(f"{C.FAIL}Access Denied: Not an Official.{C.END}"); return
        
        print(f"{C.GREEN}Welcome, {profile['RankTitle']} {profile['LastName']}{C.END}")
        official_dashboard(conn, profile)
    except Exception as e:
        print(f"{C.FAIL}Error: {e}{C.END}")

# --- MAIN LOOP ---

def citizen_mode(conn):
    try:
        cid_input = input(f"\n{C.CYAN}Enter Citizen ID: {C.END}").strip()
        if not cid_input.isdigit():
            print(f"{C.FAIL}Invalid ID format.{C.END}")
            return
        
        cid = int(cid_input)
        profile = get_citizen_details(conn, cid)
        
        if not profile:
            print(f"{C.FAIL}Citizen ID not found.{C.END}")
            return
        
        print(f"{C.GREEN}Authentication Successful.{C.END}")
        draw_id_card(profile)
        
        while True:
            print(f"\n{C.BOLD}:: CITIZEN DASHBOARD ::{C.END}")
            print("1. Identity Card")
            print("2. My Visas")
            print("3. My Assets")
            print("4. My Transactions")
            print("5. Public Records")
            print("q. Logout")
            
            choice = input(f"\n{C.CYAN}Select Action > {C.END}").strip().lower()
            
            if choice == '1': draw_id_card(profile)
            elif choice == '2': view_visas(conn, cid)
            elif choice == '3': view_assets(conn, cid)
            elif choice == '4': view_transactions(conn, cid)
            elif choice == '5': view_public_data(conn, profile)
            elif choice == 'q': break
            else: print(f"{C.WARNING}Invalid selection.{C.END}")

    except Exception as e:
        print(f"{C.FAIL}Error: {e}{C.END}")

def main():
    conn = get_connection()
    while True:
        print_header("Mini World Access Terminal")
        print("1. Citizen Login")
        print("2. Official Login")
        print("q. Exit System")
        
        mode = input(f"\n{C.CYAN}Select Mode > {C.END}").strip().lower()
        
        if mode == '1': citizen_mode(conn)
        elif mode == '2': official_mode(conn)
        elif mode == 'q': break
    conn.close()

if __name__ == "__main__":
    main()
