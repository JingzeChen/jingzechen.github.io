# Jingze's Garden 安全策略

## 支持范围

本站是持续部署的静态网站，不按 Chirpy 主题版本提供安全支持。支持范围是：

| 对象 | 状态 |
| --- | :---: |
| `main` / `master` 当前代码与线上部署 | 支持 |
| 历史提交、个人 Fork 和本地修改版本 | 不支持 |
| 未经本站修改的 Chirpy 上游缺陷 | 请同时向上游报告 |

安全问题包括但不限于跨站脚本、依赖供应链风险、敏感信息泄露、Service Worker/PWA 缓存越权、
GitHub Actions 权限问题和可导致访问者执行非预期内容的资源注入。普通内容错误、失效链接和界面缺陷
请按 [贡献指南](CONTRIBUTING.md) 提交 Issue。

## 私下报告漏洞

请发送邮件至 `jingzechennm@gmail.com`；若仓库页面提供入口，也可以使用 GitHub 的
[Private vulnerability reporting](https://github.com/JingzeChen/jingzechen.github.io/security/advisories/new)。
不要在公开 Issue、Discussion 或社交媒体中披露尚未修复的漏洞。

报告请包含：

- 受影响的 URL、文件或工作流；
- 漏洞类型、影响范围和所需前置条件；
- 可复现步骤或最小验证代码；
- 已知缓解方式；
- 是否已经向第三方或 Chirpy 上游报告。

请只使用验证漏洞所需的最少数据，不要访问、修改或公开他人的数据，不要执行拒绝服务测试，也不要
在报告中发送密码、Token、Cookie 或其他真实凭据。收到报告后会尽快确认、评估影响并协调修复与披露。
