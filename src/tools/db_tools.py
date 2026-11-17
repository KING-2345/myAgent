# src/tools/db_tools.py
from langchain_core.tools import tool
from db.connection import get_db_connection  # 导入连接数据库的函数


@tool
def query_database(sql: str) -> str:
    """
    执行只读的 SQL 查询。当你需要获取 Olist 电商的数据时，使用此工具。
    输入必须是合法的 MySQL SELECT 语句。
    """
    sql_upper = sql.strip().upper()
    if not sql_upper.startswith("SELECT"):
        return "❌ 错误：安全风控拦截，仅允许执行 SELECT 查询！"

    # 防爆内存，自动加 LIMIT
    if "LIMIT" not in sql_upper and "COUNT(" not in sql_upper:
        sql = sql.strip().rstrip(";") + " LIMIT 20;"

    try:
        # 👇 调用底层数据库连接，执行 SQL
        conn = get_db_connection()
        with conn.cursor() as cursor:
            cursor.execute(sql)
            result = cursor.fetchall()
        conn.close()

        if not result:
            return "查询成功，但未找到符合条件的数据。"

        if len(result) > 20:
            return f"查询成功，共 {len(result)} 条数据。以下仅展示前 20 条：\n{result[:20]}"

        return f"查询结果：\n{result}"

    except Exception as e:
        return f"SQL 执行失败，错误信息：{str(e)}。请检查表名和字段名，修改后重试。"



