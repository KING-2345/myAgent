from langchain_core.tools import tool
from tavily import TavilyClient
import os


tavily_client = TavilyClient(api_key=os.getenv("TAVILY_API_KEY"))
@tool
def web_search(query: str) -> str:
    """ 联网工具，帮助agent联网搜索信息，提高用户体验 """
    try:
        # 1.调用搜索接口
        result = tavily_client.search(query, max_results=3)  # 只取前三条，防爆token
        # return result

        # 2.强力清洗数据(可通过注释该段代码,并在result下一行写入 return result ,测试清清晰效果)
        lines = []
        for items in result.get("results", []):
            lines.append(f"标题:{items.get('title','')}")
            lines.append(f"网址:{items.get('url','')}")
            lines.append(f"摘要:{items.get('content','')[:300]}")  # 截断摘要，只取前300字
            lines.append("-----------------------")

        cleaned_text = "\n".join(lines)
        return cleaned_text if cleaned_text else "为搜索到相关结果。"

    except Exception as e:
        # 3.异常兜底放崩溃
        return f"搜索失败,错误信息:{str(e)}"

