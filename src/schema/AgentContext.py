from dataclasses import dataclass


@dataclass
class AgentContext:
    user_id: str = "test_user",
    role: str = "user"  # admin, vip, user
    is_authenticated: bool = True  # 用户是否验证通过
