import os
from langchain.chat_models import init_chat_model
from langchain.agents import create_agent
from dotenv import load_dotenv

load_dotenv()

model = init_chat_model(
    model='glm-4-flash',
    model_provider='openai'
)

agent = create_agent(
    model = model
)

response = agent.invoke(
    {"messages":[{"role":"user", "content":"你是什么模型"}]}
)

print(response["messages"][-1].content)
