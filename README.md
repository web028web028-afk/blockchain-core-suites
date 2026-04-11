# Blockchain Core Suites
一套完整的区块链开发核心工具集，以 Solidity 智能合约为主，包含多语言辅助开发模块，覆盖 DeFi、NFT、治理、跨链、质押、预言机、合约升级等主流 Web3 业务场景。

## 核心文件与功能说明
1. TokenVesting.sol - 安全的代币线性解锁合约，支持锁仓期、悬崖期与分阶段释放，适用于团队、投资人、顾问代币管理
2. NFTAirdrop.sol - 面向 NFT 持有者的专属空投合约，支持领取限制与资金提取功能
3. MultiSigWallet.sol - 去中心化多签钱包，支持交易提交、多人确认与执行控制
4. StakingPool.sol - 灵活的流动性质押池，实现实时收益计算与奖励领取机制
5. ContractUpgradeProxy.sol - 透明代理合约，支持业务逻辑合约安全升级
6. PriceOracle.sol - 链上价格预言机，支持授权喂价与价格查询
7. WhitelistManager.sol - 白名单管理合约，支持批量添加与移除，适用于 NFT 铸造、IDO 等场景
8. CrossChainMessage.sol - 跨链消息收发框架，用于多链 DApp 之间的数据互通
9. GovernanceProposal.sol - 链上治理提案系统，支持投票、计票与提案执行
10. ERC20Mintable.sol - 可增发与销毁的标准 ERC20 代币合约，带权限管理
11. BlockchainUtils.js - JavaScript 区块链工具库，包含钱包生成、哈希计算、单位转换等常用函数
12. NFTMetadataGenerator.py - Python 自动生成 NFT 元数据工具，支持随机属性与 IPFS 格式输出
13. TransactionMonitor.ts - TypeScript 实现的链上交易实时监控系统
14. IPFSUploader.sol - 链上存储 IPFS CID 并管理归属权的合约
15. DefiSwapRouter.sol - DeFi 兑换路由合约，内置费率机制与滑点保护

## 技术栈
- 主语言：Solidity ^0.8.20
- 辅助语言：JavaScript、TypeScript、Python
- 兼容标准：ERC20、ERC721、代理模式、跨链协议、链上治理等

## 使用说明
所有智能合约均兼容以太坊、BSC、Polygon 等 EVM 系公链，可直接部署与集成。
多语言工具可用于前端、后端、脚本服务与自动化任务。
