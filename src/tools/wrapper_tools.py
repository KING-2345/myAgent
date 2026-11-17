from .local_tools import  web_search
from .db_tools import query_database
# from ... import ...


def all_tools():
    """ 整合所有用到的工具,返回一个列表形式的整体,方便创建agent """

    tool_list = [
        query_database,
        web_search
    ]

    return tool_list