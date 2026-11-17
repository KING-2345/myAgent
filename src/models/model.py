from langchain.chat_models import init_chat_model

lowerModel = init_chat_model(
    model = "glm-4-air",
    model_provider="openai"
)
strongerModel = init_chat_model(
    model="",
    model_provider="openai"
)