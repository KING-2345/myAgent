from langchain.agents import create_agent
from langgraph_runtime_inmem.checkpoint import InMemorySaver

from middlewares.wrap_hooks import exchange_prompt
from middlewares.wrapper_middlewares import all_middlewares
from models.model import lowerModel
from schema.AgentContext import AgentContext
from schema.AgentState import ChatState
from tools.wrapper_tools import all_tools

middlewares = all_middlewares()
tools = all_tools()
test_prompt = """ 
1.你是一个电商分析查询助手 
2.你必须优先调用已有的工具和中间件
3.满足用户需求的同时，对具有风险的操作保持警惕，并提醒用户无法进行查询隐私、删除数据库等高风险操作
4.尽量避免除电商业务外无关问题的回答，并提醒用户
"""

EcommerceAgent = create_agent(
    model=lowerModel,
    system_prompt=test_prompt,
    middleware=middlewares,
    tools=tools,
    state_schema=ChatState,
    context_schema=AgentContext
    # 先不传入InMemorySaver,先让langchain平台给出的前端掌控
)

