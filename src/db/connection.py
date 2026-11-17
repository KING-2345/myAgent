import os
import pymysql
from dotenv import load_dotenv

load_dotenv()

def get_db_connection():
    """ 获取MySQL数据库链接 """
    return pymysql.connect(
        host = os.getenv("MYSQL_HOST", "127.0.0.1"),
        port = int(os.getenv("MYSQL_PORT", 3306)),
        user = os.getenv("MYSQL_USER", "root"),
        password = os.getenv("MYSQL_PASSWORD", ""),
        database = os.getenv("MYSQL_DB", "olist"),
        cursorclass = pymysql.cursors.DictCursor
    )