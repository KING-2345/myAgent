from langchain.agents import AgentState
from langchain.agents.middleware import after_agent, before_model
from langchain_core.messages import ToolMessage, RemoveMessage, AIMessage, HumanMessage, SystemMessage
from langgraph.runtime import Runtime
import re
from models.model import lowerModel


@after_agent
def CleanToolmessages_afterAgent(state: AgentState,runtime: Runtime) -> dict | None:
    """ 在agent完成工作后，清理输出工具消息，只返回AI消息 """
    messages = state["messages"]
    tl_messages = [msg for msg in messages if isinstance(msg, ToolMessage)]
    if not tl_messages:
        return None
    remove_list = [RemoveMessage(id=msg.id) for msg in tl_messages]
    return {"messages": remove_list}

@before_model
def clean_history_tools(state: AgentState, runtime:Runtime) -> dict | None:
    """ 在模型思考前，清理历史堆积的工具消息，防止上下文过长 """
    messages = state["messages"]
    remove_list = []

    for i,msg in enumerate(messages[:-2]):  #留出最后两条消息作为安全缓冲
        if isinstance(msg,ToolMessage):
            # 检查该条消息工具后是否有模型总结回复，证明大模型以及看过该消息
            has_been_processed = any(
                isinstance(next_msg,AIMessage)
                for next_msg in messages[i+1:]
            )
            if has_been_processed:
                remove_list.append(RemoveMessage(id=msg.id))
        if remove_list:
            print(f"[中间件clean_history_tools]清理了{len(remove_list)}条历史工具消息")
            return {"messages":remove_list}

        return None

@before_model
def filter_pii(state: AgentState, runtime: Runtime) -> dict | None:
    """在模型思考前，过滤用户输入中的手机号、身份证号等敏感隐私信息"""
    messages = state["messages"]
    if not messages:
        return None

    # 拿到最后一条用户消息
    last_msg = messages[-1]
    if not isinstance(last_msg, HumanMessage) or not isinstance(last_msg.content, str):
        return None
    content = last_msg.content
    # 正则匹配手机号（11位）和身份证号（18位）
    new_content = re.sub(r'1[3-9]\d{9}', '[手机号已脱敏]', content)
    new_content = re.sub(r'\d{17}[\dXx]', '[身份证号已脱敏]', new_content)

    # 如果内容发生了变化，说明命中了敏感词，我们替换掉原消息
    if new_content != content:
        print("[中间件 PII] 检测到隐私信息，已进行脱敏处理！")
        # 核心技巧：创建一条新消息，但 id 必须和原消息一致，才能覆盖原消息
        new_msg = HumanMessage(content=new_content, id=last_msg.id)
        return {"messages": [new_msg]}
    return None

