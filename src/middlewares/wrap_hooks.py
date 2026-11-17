from langchain.agents.middleware import wrap_model_call, dynamic_prompt, ModelRequest, ModelResponse
from datetime import datetime
from typing import Callable
from langchain_core.messages import SystemMessage

@wrap_model_call
async def dynamic_model():
    """ 根据业务需求动态切换模型 """
    pass


@wrap_model_call
async def inject_time(request: ModelRequest, handler: Callable[[ModelRequest], ModelResponse]) -> ModelResponse:
    """无痕注入当前时间（不污染 state 上下文）"""
    # 获取当前时间，并进行格式化
    now_str = datetime.now().strftime("%Y年%m月%d日 %H:%M:%S")

    # 伪装成系统消息
    time_msg = SystemMessage(content=f"【系统提示】当前的真实时间是：{now_str}。")

    # 临时塞进这次请求的头部，不存进 State
    request = request.override(messages=[time_msg] + request.messages)
    return await handler(request)

@wrap_model_call
async def exchange_tool():
    """ 根据业务和用户身份动态提供工具 """
    pass


@dynamic_prompt
async def exchange_prompt():
    """ 根据业务和用户身份动态切换提示词 """
    base_prompt = """数据库包含 155 万行真实数据。严禁执行不带 LIMIT 的全表扫描！除非用户要求统计总数（COUNT），否则每次查询最多只能返回 20 条明细。"""

    pass

