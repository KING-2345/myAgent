from langchain.agents.middleware import SummarizationMiddleware, HumanInTheLoopMiddleware

from models.model import lowerModel
from .node_hooks import filter_pii, clean_history_tools, CleanToolmessages_afterAgent
from .wrap_hooks import inject_time

# from ... import ...

def all_middlewares():
    """ 整合所有中间件,返回一个列表形式的整体,供agent使用 """
    # 总结消息，减少上下文长度
    compressContext_middleware = [
        SummarizationMiddleware(
            model = lowerModel,
            trigger=("tokens", 3000),
            keep=("messages",5)
        )
    ]

    # 人在环中，加入人类审批流程
    HITL = [
        HumanInTheLoopMiddleware(
            interrupt_on = {

            }
        )
    ]

    middleware_list = compressContext_middleware + [
        # 先不传入HITL，后续工具完成后再传入
        inject_time, # 这里仅仅传入了一个缠绕钩子，后续缠绕钩子根据业务的逐渐完成慢慢添加
        filter_pii,
        clean_history_tools,
        CleanToolmessages_afterAgent
    ]
    return middleware_list


