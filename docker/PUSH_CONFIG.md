# BiliTool Web版推送功能配置说明

## 🎯 功能概述

BiliTool Web版现已完整支持推送功能！当任务执行完成后，会自动将结果推送到您配置的平台。

## 📱 支持的推送平台

| 序号 | 推送平台 | 配置难度 | 推荐度 |
|------|----------|----------|--------|
| 1 | PushPlus | ⭐ | ⭐⭐⭐⭐⭐ |
| 2 | Telegram | ⭐⭐ | ⭐⭐⭐⭐⭐ |
| 3 | 企业微信机器人 | ⭐⭐ | ⭐⭐⭐⭐ |
| 4 | 钉钉机器人 | ⭐⭐ | ⭐⭐⭐⭐ |
| 5 | Server酱 | ⭐ | ⭐⭐⭐ |
| 6 | 企业微信应用 | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| 7 | Microsoft Teams | ⭐⭐ | ⭐⭐⭐ |
| 8 | 酷推QQ | ⭐⭐ | ⭐⭐ |
| 9 | Gotify | ⭐⭐ | ⭐⭐⭐ |
| 10 | 自定义API | ⭐⭐⭐ | ⭐⭐⭐ |

## 🚀 快速开始 - PushPlus推送（推荐）

### 1. 获取PushPlus Token

1. 访问 [PushPlus官网](http://www.pushplus.plus/)
2. 使用微信扫码登录
3. 复制您的Token

### 2. 配置环境变量

在`docker-compose.yml`中添加：

```yaml
environment:
  - Ray_Serilog__WriteTo__9__Args__token=your_pushplus_token
  - Ray_Serilog__WriteTo__9__Args__restrictedToMinimumLevel=Information
```

### 3. 重启容器

```bash
docker compose down
docker compose up -d
```

## 📋 详细配置说明

### Telegram推送

```yaml
environment:
  - Ray_Serilog__WriteTo__3__Args__botToken=your_bot_token
  - Ray_Serilog__WriteTo__3__Args__chatId=your_chat_id
  - Ray_Serilog__WriteTo__3__Args__restrictedToMinimumLevel=Information
```

### 企业微信机器人

```yaml
environment:
  - Ray_Serilog__WriteTo__4__Args__webHookUrl=your_webhook_url
  - Ray_Serilog__WriteTo__4__Args__restrictedToMinimumLevel=Information
```

### 钉钉机器人

```yaml
environment:
  - Ray_Serilog__WriteTo__5__Args__webHookUrl=your_webhook_url
  - Ray_Serilog__WriteTo__5__Args__restrictedToMinimumLevel=Information
```

### Server酱

```yaml
environment:
  - Ray_Serilog__WriteTo__6__Args__turboScKey=your_sckey
  - Ray_Serilog__WriteTo__6__Args__restrictedToMinimumLevel=Information
```

## 🔧 完整的docker-compose.yml示例

```yaml
version: '3.8'

services:
  bili_tool_web:
    image: ghcr.io/raywangqvq/bilibili_tool_web
    container_name: bili_tool_web
    ports:
      - "22330:8080"
    environment:
      - TZ=Asia/Shanghai
      # PushPlus推送配置
      - Ray_Serilog__WriteTo__9__Args__token=your_pushplus_token
      - Ray_Serilog__WriteTo__9__Args__restrictedToMinimumLevel=Information
      # 可选：配置推送渠道
      - Ray_Serilog__WriteTo__9__Args__channel=wechat
      # 可选：群组推送
      - Ray_Serilog__WriteTo__9__Args__topic=your_topic
    volumes:
      - ./Logs:/app/Logs
      - ./config:/app/config
    restart: unless-stopped
```

## 📝 配置参数说明

### restrictedToMinimumLevel 参数

控制推送的日志级别：

- `Verbose` - 推送所有日志（过多，不推荐）
- `Debug` - 推送调试级别以上日志
- `Information` - 推送信息级别以上日志（推荐）
- `Warning` - 只推送警告和错误
- `Error` - 只推送错误

### PushPlus Channel 参数

- `wechat` - 微信公众号（默认）
- `webhook` - 第三方webhook  
- `cp` - 企业微信应用
- `sms` - 短信
- `mail` - 邮件

## 🧪 测试推送功能

### 方法1：手动触发任务
在Web界面中手动触发一个任务，查看是否收到推送。

### 方法2：查看日志
检查`Logs/log.txt`文件，查看是否有推送相关的日志：

```
[15:00:01 INF] 开始推送·Daily·用户1
[15:00:02 INF] 推送成功 - PushPlus
```

### 方法3：等待定时任务
等待定时任务执行（如每日任务15:00），查看推送效果。

## 🔍 故障排查

### 1. 没有收到推送消息

检查以下几点：
- 确认Token/Webhook配置正确
- 确认`restrictedToMinimumLevel`设置为`Information`
- 检查容器网络连接
- 查看应用日志是否有错误信息

### 2. 推送频率过高

调整`restrictedToMinimumLevel`为`Warning`或`Error`

### 3. 推送内容格式问题

这是正常现象，推送的是原始日志内容，包含时间戳和级别信息。

## 📊 推送效果示例

配置成功后，您会收到类似这样的推送消息：

```
[15:00:01 INF] 版本号："3.0.0"
[15:00:01 INF] 开源地址："https://github.com/RayWangQvQ/BiliBiliToolPro"
[15:00:02 INF] -----开始每日任务-----
[15:00:02 INF] 登录成功，用户名: "您的用户名"
[15:00:03 INF] 硬币余额: 1234
[15:00:04 INF] 今日投币完成 (5/5)
[15:00:05 INF] -----每日任务执行完成-----
```

## 🎉 恭喜！

推送功能现已完整配置！每当BiliTool执行任务时，您都会第一时间收到通知。

---

如有问题，请查看项目的[完整文档](../docs/configuration.md)或提交Issue。 