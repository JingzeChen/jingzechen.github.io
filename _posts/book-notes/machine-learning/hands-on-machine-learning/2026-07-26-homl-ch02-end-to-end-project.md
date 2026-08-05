---
title: "《Hands-On Machine Learning with Scikit-Learn and PyTorch》第 2 章：端到端机器学习项目"
date: 2026-07-26 10:00:00 +0800
updated: 2026-08-02
uid: homl-ch02-end-to-end-project
type: reading
content_lang: zh-CN
status: growing
topics: [machine-learning, books]
series: hands-on-machine-learning
series_order: 3
related: [homl-ch01-ml-landscape, homl-ch03-classification]
references:
    - { title: "Chapter companion notebook", url: "https://homl.info/colab-p", note: "Interactive notebooks for the PyTorch edition." }
    - { title: "Hands-On Machine Learning companion repository", url: "https://github.com/ageron/handson-mlp" }
categories: [读书笔记, 机器学习, Hands-On Machine Learning]
tags: [machine-learning, hands-on-ml, reading-notes]
description: 以完整项目为线索，梳理数据准备、模型训练、评估和上线前检查的工程流程。
toc: true
math: true
mermaid: true
---

> 原书：*Hands-On Machine Learning with Scikit-Learn and PyTorch*  
> 章节：Chapter 2, End-to-End Machine Learning Project  
> 案例：使用加州人口普查数据预测地区房价中位数  
> 配套 Notebook：<https://homl.info/colab-p>

## 本章目标

本章不是单独讲某个算法，而是演示一个机器学习项目从业务问题到生产维护的完整生命周期。学完后应当能够：

1. 把业务目标转化为机器学习任务和评价指标；
2. 在查看数据前留出测试集，避免数据窥探；
3. 只使用训练集进行探索性数据分析；
4. 用 Scikit-Learn Pipeline 构建可复现的数据预处理流程；
5. 使用交叉验证比较模型并识别欠拟合、过拟合；
6. 使用网格搜索或随机搜索调整超参数；
7. 在测试集上做一次最终评估并给出置信区间；
8. 保存、部署、监控并定期更新模型。

## 一句话概括

一个可靠的机器学习项目不是“选模型并调用 `fit()`”，而是围绕业务目标建立一条可复现、无数据泄漏、可评估、可部署并能持续维护的完整流水线。

## 1. 全章工作流

```mermaid
flowchart LR
    A[理解全局] --> B[获取数据]
    B --> C[探索与可视化]
    C --> D[准备数据]
    D --> E[选择并训练模型]
    E --> F[微调模型]
    F --> G[展示解决方案]
    G --> H[上线、监控与维护]
    H --> B
```

八个步骤不是一次性的直线流程。错误分析可能让你返回特征工程，生产中的数据漂移也会触发重新收集数据和训练模型。

## 2. 理解全局

### 2.1 从业务目标开始

项目目标是根据加州各地区的人口普查特征预测房价中位数。预测结果会提供给下游系统，帮助决定某个地区是否值得投资。

首先要问：

- 模型输出会被谁使用？
- 下游系统需要连续价格，还是价格类别？
- 当前解决方案是什么，误差和成本如何？
- 错误预测会造成什么业务后果？
- 延迟、内存、吞吐量和可解释性有什么要求？

业务目标决定模型指标。不能脱离使用场景，只追求一个看起来漂亮的离线分数。

### 2.2 问题建模

本项目属于：

| 分类维度 | 结论 | 原因 |
| --- | --- | --- |
| 监督方式 | 监督学习 | 每个地区都有目标房价 |
| 任务类型 | 回归 | 输出是连续数值 |
| 输入输出 | 多元单输出回归 | 多个特征预测一个房价值 |
| 训练方式 | 批量学习 | 数据量有限，变化不需要实时吸收 |
| 泛化方式 | 基于模型 | 从数据中拟合参数并预测新地区 |

### 2.3 系统 Pipeline

项目通常只是更大系统中的一个组件。上游组件提供数据，下游组件消费预测结果。这种数据处理组件序列称为 Pipeline。

Pipeline 的价值：

- 每个组件接口清晰；
- 可以独立开发、复用和监控；
- 某个组件失败时可采用回退策略；
- 训练和推理能共享相同的数据变换。

但长 Pipeline 也可能隐藏问题：上游输出分布缓慢变化，下游模型未必立即报错，却可能持续产生质量下降的预测。因此每个关键边界都应监控数据质量和分布。

### 2.4 选择性能指标

#### RMSE

回归任务最常见的指标是均方根误差：

$$
\operatorname{RMSE}(\mathbf{X}, h)
= \sqrt{\frac{1}{m}\sum_{i=1}^{m}
\left(h(\mathbf{x}^{(i)})-y^{(i)}\right)^2}
$$

其中：

- $m$：参与评估的实例数；
- $\mathbf{x}^{(i)}$：第 $i$ 个实例的特征向量；
- $y^{(i)}$：真实目标值；
- $h(\mathbf{x}^{(i)})$：模型预测值；
- $\mathbf{X}$：所有实例的特征矩阵。

RMSE 与目标变量单位相同，较大的误差会因平方受到更重惩罚。当大误差非常不可接受时，它是合理选择。

#### MAE

若数据包含较多异常值，平均绝对误差往往更稳健：

$$
\operatorname{MAE}(\mathbf{X}, h)
= \frac{1}{m}\sum_{i=1}^{m}
\left|h(\mathbf{x}^{(i)})-y^{(i)}\right|
$$

RMSE 对应误差向量的 $L_2$ 范数，MAE 对应 $L_1$ 范数。范数阶数越高，对大值的关注越强。

### 2.5 检查假设

在继续前应和下游团队确认：系统是否真的需要一个精确房价值。如果下游只把价格分成“低、中、高”三类，那么任务可能应改成分类，整个数据准备、指标和模型选择都会随之改变。

## 3. 获取数据

### 3.1 数据来源与字段

本章使用 1990 年加州人口普查数据的修改版本。每行代表一个地区，而不是一栋房屋。

| 字段 | 含义 | 类型/注意点 |
| --- | --- | --- |
| `longitude` | 经度 | 数值 |
| `latitude` | 纬度 | 数值 |
| `housing_median_age` | 房龄中位数 | 数值，存在上限截断 |
| `total_rooms` | 房间总数 | 数值 |
| `total_bedrooms` | 卧室总数 | 数值，存在缺失值 |
| `population` | 人口数 | 数值，长尾分布 |
| `households` | 家庭数 | 数值 |
| `median_income` | 收入中位数 | 数值，已做尺度处理 |
| `ocean_proximity` | 与海洋的位置关系 | 类别 |
| `median_house_value` | 房价中位数 | 预测目标，存在上限截断 |

数据文件应通过代码自动下载和解压，使任何人都能在干净环境中重现项目，而不是依赖手工准备。

### 3.2 快速检查数据结构

```python
housing.head()
housing.info()
housing.describe()
housing["ocean_proximity"].value_counts()
housing.hist(bins=50, figsize=(12, 8))
```

重点观察：

- 每列的数据类型；
- 缺失值数量；
- 数值范围、均值、标准差和分位数；
- 类别取值及频数；
- 分布是否长尾；
- 某些列是否被缩放或设置上限。

本数据中需要特别注意：

- `total_bedrooms` 有缺失值；
- `median_income` 并不是直接以美元表示；
- `housing_median_age` 与目标 `median_house_value` 存在截断；
- 多个特征呈明显长尾分布。

目标值被截断尤其重要。如果模型必须准确预测高于该上限的价格，可以收集这些地区的真实标签，或从训练集和测试集中剔除这些地区；具体选择必须由业务需求决定。

### 3.3 Notebook 的交互性风险

Notebook 允许任意顺序运行单元格，既方便实验，也容易让内存状态与文档顺序不一致。

实践规则：

- 经常执行“Restart Kernel and Run All”；
- 保证从空内核按顺序运行能够复现结果；
- 不依赖已经被覆盖但未在文档中体现的变量；
- 固定随机种子；
- 把关键逻辑封装为函数、Transformer 或 Pipeline。

### 3.4 创建测试集

测试集必须在深入探索数据前创建。否则观察完整数据得到的规律会影响模型和特征设计，使测试结果过于乐观，这叫**数据窥探偏差**。

简单随机划分：

```python
from sklearn.model_selection import train_test_split

train_set, test_set = train_test_split(
    housing, test_size=0.2, random_state=42
)
```

`random_state` 使当前数据上的划分可复现。如果数据集会不断更新，还可根据每条实例的稳定唯一标识计算哈希值，确保同一个实例始终落在同一侧。

### 3.5 分层抽样

专家判断收入中位数是预测房价的重要特征。如果测试集中各收入层比例与总体差异太大，评估就不可靠。

**分层抽样（stratified sampling）**是先按照某个重要特征把总体划分为若干互不重叠的群体（层），再按各层在总体中的比例分别抽样。它不只是随机决定“抽到哪些实例”，还会控制“每一类实例抽到多少”，使训练集和测试集在关键特征上的分布尽量接近完整数据集。

操作过程可以概括为：

1. 选择与目标高度相关或业务上必须保证覆盖的分层依据；
2. 如果该特征是连续变量，先将它划分为少量区间；
3. 按每层在总体中的比例划分训练集和测试集；
4. 划分完成后删除仅用于抽样的临时分层字段。

先把连续收入分桶：

```python
housing["income_cat"] = pd.cut(
    housing["median_income"],
    bins=[0.0, 1.5, 3.0, 4.5, 6.0, np.inf],
    labels=[1, 2, 3, 4, 5],
)
```

再分层划分：

```python
strat_train_set, strat_test_set = train_test_split(
    housing,
    test_size=0.2,
    stratify=housing["income_cat"],
    random_state=42,
)
```

`stratify=housing["income_cat"]` 要求划分结果尽量保留各收入层的原始比例。例如某收入层占总体的 30%，它在训练集和测试集中也应分别占约 30%。这能降低随机划分造成的采样误差，使测试集更具代表性，尤其适合数据量较小或类别不平衡的情况。分类任务通常直接使用目标标签分层：

```python
X_train, X_test, y_train, y_test = train_test_split(
    X,
    y,
    test_size=0.2,
    stratify=y,
    random_state=42,
)
```

使用时需要注意：

- 分层依据应真正重要，不要同时按大量特征随意分层；
- 连续变量必须先合理分桶，层数不能过多；
- 每层都必须有足够样本，否则无法稳定划分；
- 分层抽样只能减少划分时的采样误差，不能修复原始数据本身的采样偏差；
- `income_cat` 仅用于抽样，不一定适合作为模型特征，划分后应从两个集合中删除。

可以简单记为：**普通随机抽样关心抽到谁，分层抽样还关心各类样本分别抽到多少。**

> 核心纪律：从此只探索训练集，测试集锁定到项目最后。

## 4. 探索和可视化数据

先创建训练集副本，避免探索过程意外修改原数据：

```python
housing = strat_train_set.copy()
```

### 4.1 地理可视化

普通经纬度散点图可以显示加州轮廓。加入透明度能显示数据点密度：

```python
housing.plot(
    kind="scatter", x="longitude", y="latitude", alpha=0.2
)
```

进一步让点大小表示人口、颜色表示房价：

```python
housing.plot(
    kind="scatter",
    x="longitude",
    y="latitude",
    s=housing["population"] / 100,
    c="median_house_value",
    cmap="jet",
    colorbar=True,
    alpha=0.4,
)
```

可观察到：

- 房价与地理位置关系明显；
- 湾区、洛杉矶和圣地亚哥附近价格较高；
- 人口密度也是重要信号；
- 仅靠经纬度的原始数值可能难以表达复杂的局部地理模式。

### 4.2 相关系数

Pearson 相关系数：

$$
r \in [-1, 1]
$$

- 接近 $1$：强正线性关系；
- 接近 $-1$：强负线性关系；
- 接近 $0$：没有明显线性关系，但仍可能存在强非线性关系。

```python
corr_matrix = housing.corr(numeric_only=True)
corr_matrix["median_house_value"].sort_values(ascending=False)
```

本数据中 `median_income` 与房价的正相关最明显。可用散点矩阵或单独的散点图进一步观察相关特征。

必须注意：相关不等于因果；Pearson 系数只测量线性关系；目标值截断还会在散点图中产生明显水平线。

### 4.3 尝试特征组合

原始总量往往不如比例有意义：

```python
housing["rooms_per_house"] = (
    housing["total_rooms"] / housing["households"]
)
housing["bedrooms_ratio"] = (
    housing["total_bedrooms"] / housing["total_rooms"]
)
housing["people_per_house"] = (
    housing["population"] / housing["households"]
)
```

直觉：

- 每户房间数比地区总房间数更能描述居住空间；
- 卧室占比低可能意味着住宅拥有更多其他功能房间；
- 每户人口数能描述居住拥挤程度。

EDA 是迭代过程。先获得初步洞察，建立模型并分析错误后，再返回探索和特征工程。

## 5. 为算法准备数据

### 5.1 为什么要自动化预处理

不要手工修改数据，应编写可复用的预处理组件，因为它们能够：

- 在任意数据集上重复执行；
- 形成可测试、可维护的变换库；
- 在调参时比较不同方案；
- 保证训练与生产推理使用完全相同的步骤；
- 与交叉验证结合，防止验证折信息泄漏到训练折。

先分离特征与标签：

```python
housing = strat_train_set.drop("median_house_value", axis=1)
housing_labels = strat_train_set["median_house_value"].copy()
```

### 5.2 清洗缺失值

对于 `total_bedrooms`，可以：

1. 删除缺失实例；
2. 删除整个属性；
3. 用统计量填补缺失值。

通常使用中位数填补：

```python
from sklearn.impute import SimpleImputer

imputer = SimpleImputer(strategy="median")
housing_num = housing.select_dtypes(include=[np.number])
housing_num_imputed = imputer.fit_transform(housing_num)
```

应对所有数值列学习中位数，而不仅是当前存在缺失的列，因为生产数据中的其他列以后也可能缺失。

常用 API：

- `fit()`：从训练数据学习统计量；
- `transform()`：把已经学到的规则应用到数据；
- `fit_transform()`：在同一训练数据上依次执行二者；
- `statistics_`：以尾随下划线保存训练后学到的中位数。

> 防泄漏原则：插补器只能在训练数据上 `fit()`，再用于验证集、测试集和生产数据的 `transform()`。

### 5.3 Scikit-Learn 设计约定

- **Estimator**：通过 `fit()` 估计参数；
- **Transformer**：通过 `transform()` 改变数据，常提供 `fit_transform()`；
- **Predictor**：通过 `predict()` 进行预测，常提供 `score()`；
- 构造函数中的配置是超参数；
- 从数据学到的属性通常以 `_` 结尾；
- 数据通常以 NumPy 数组或 SciPy 稀疏矩阵表示；
- 组件尽量无状态、接口一致，便于组合和自动调参。

### 5.4 处理类别特征

`ocean_proximity` 是无自然顺序的名义类别。

`OrdinalEncoder` 将类别映射为整数，但会暗示类别之间存在距离和顺序，因此不适合这里：

```python
from sklearn.preprocessing import OrdinalEncoder
```

应使用独热编码：

```python
from sklearn.preprocessing import OneHotEncoder

cat_encoder = OneHotEncoder(handle_unknown="ignore")
housing_cat_1hot = cat_encoder.fit_transform(housing[["ocean_proximity"]])
```

默认输出稀疏矩阵，能避免类别很多时存储大量零。需要密集数组时可设置 `sparse_output=False`。

使用 `handle_unknown="ignore"` 后，推理时出现训练阶段未见过的类别不会报错，而是编码为全零。生产 Pipeline 通常应优先使用 `OneHotEncoder`，而非难以稳定处理未知类别的 `pd.get_dummies()`。

### 5.5 特征缩放

许多算法在输入特征尺度差异大时表现不佳。常见方法：

#### Min-Max 缩放

$$
x' = \frac{x-x_{\min}}{x_{\max}-x_{\min}}
$$

通常映射到 $[0,1]$，也可用 `feature_range` 指定其他区间。

#### 标准化

$$
x' = \frac{x-\mu}{\sigma}
$$

`StandardScaler` 使特征均值接近 0、标准差接近 1。它不像 Min-Max 缩放那样固定输出范围，而且受异常值影响通常小得多，但它并非真正的稳健统计方法；存在严重异常值时仍可考虑先处理异常值或使用 `RobustScaler`。对稀疏矩阵标准化时可设置 `with_mean=False`，避免减去均值破坏稀疏性。

> 缩放器只能在训练数据上 `fit()`，然后用同一参数变换验证、测试和生产数据。通常不需要缩放目标值；若需要，应在预测后做逆变换。

### 5.6 处理长尾分布

`population` 等特征呈重尾分布，直接缩放后大部分值可能被挤在很小范围内。常见处理包括：

- 对正值取对数；
- 对轻度长尾取平方根；
- 分桶；
- 使用分位数变换；
- 计算与某个关键值的 RBF 相似度。

对数变换示例：

```python
from sklearn.preprocessing import FunctionTransformer

log_transformer = FunctionTransformer(np.log, inverse_func=np.exp)
```

高斯 RBF 相似度：

$$
\operatorname{RBF}(x, \ell)=\exp\left(-\gamma\lVert x-\ell\rVert^2\right)
$$

`gamma` 越大，相似度随距离下降越快。它可以把“离某个有意义数值多近”变成一个模型更容易使用的特征。

### 5.7 自定义 Transformer

当内置变换不能满足需求时，可以创建遵循 Scikit-Learn API 的 Transformer。书中使用 K-Means 找到地理簇中心，再输出每个地区与各中心的 RBF 相似度：

```python
from sklearn.base import BaseEstimator, TransformerMixin
from sklearn.cluster import KMeans
from sklearn.metrics.pairwise import rbf_kernel


class ClusterSimilarity(BaseEstimator, TransformerMixin):
    def __init__(self, n_clusters=10, gamma=1.0, random_state=None):
        self.n_clusters = n_clusters
        self.gamma = gamma
        self.random_state = random_state

    def fit(self, X, y=None, sample_weight=None):
        self.kmeans_ = KMeans(
            self.n_clusters,
            random_state=self.random_state,
        )
        self.kmeans_.fit(X, sample_weight=sample_weight)
        return self

    def transform(self, X):
        return rbf_kernel(
            X,
            self.kmeans_.cluster_centers_,
            gamma=self.gamma,
        )

    def get_feature_names_out(self, names=None):
        return [
            f"Cluster {index} similarity"
            for index in range(self.n_clusters)
        ]
```

约定：

- `__init__` 只保存超参数，不执行训练逻辑；
- `fit()` 返回 `self`；
- 学到的状态使用尾随 `_`；
- 提供 `get_feature_names_out()` 便于检查输出；
- 继承 `BaseEstimator` 后可使用 `get_params()`、`set_params()` 和自动调参。

### 5.8 Pipeline 与 ColumnTransformer

数值 Pipeline：

```python
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler

num_pipeline = make_pipeline(
    SimpleImputer(strategy="median"),
    StandardScaler(),
)
```

Pipeline 会在 `fit()` 时依次拟合并转换前面的 Transformer，再拟合最后一个 Estimator；在 `predict()` 时依次执行已拟合的变换，再调用最终模型预测。

对不同列执行不同处理：

```python
from sklearn.compose import ColumnTransformer

preprocessing = ColumnTransformer([
    ("num", num_pipeline, numerical_columns),
    ("cat", OneHotEncoder(handle_unknown="ignore"), categorical_columns),
    ("geo", ClusterSimilarity(random_state=42), ["latitude", "longitude"]),
])
```

完整 Pipeline 将预处理和模型绑在一起：

```python
from sklearn.ensemble import RandomForestRegressor

full_pipeline = make_pipeline(
    preprocessing,
    RandomForestRegressor(random_state=42),
)
```

这一步非常关键：交叉验证的每一折都会只在该折训练部分拟合插补、编码和缩放参数，从而避免验证信息泄漏。

若需要变换目标变量，可使用 `TransformedTargetRegressor`。它会在训练时变换 `y`，在预测时自动执行逆变换：

```python
from sklearn.compose import TransformedTargetRegressor

target_model = TransformedTargetRegressor(
    regressor=full_pipeline,
    transformer=StandardScaler(),
)
```

## 6. 选择并训练模型

### 6.1 先建立多个基线

#### 线性回归

```python
from sklearn.linear_model import LinearRegression

lin_reg = make_pipeline(preprocessing, LinearRegression())
lin_reg.fit(housing, housing_labels)
```

训练集 RMSE 约为 $68{,}973$，误差较大，说明模型明显欠拟合。改进方向包括增加有效特征或使用更强模型。

#### 决策树

```python
from sklearn.tree import DecisionTreeRegressor

tree_reg = make_pipeline(
    preprocessing,
    DecisionTreeRegressor(random_state=42),
)
```

训练集 RMSE 为 $0$ 并不表示模型完美，更可能是决策树记住了训练数据，发生严重过拟合。

#### 随机森林

随机森林组合许多决策树的结果，通常能显著降低单棵树的方差。其训练误差仍可能明显低于验证误差，因此也要检查过拟合。

### 6.2 使用交叉验证可靠评估

```python
from sklearn.model_selection import cross_val_score

tree_rmses = -cross_val_score(
    tree_reg,
    housing,
    housing_labels,
    scoring="neg_root_mean_squared_error",
    cv=10,
)
```

Scikit-Learn 的评分约定是“越大越好”，所以损失类指标以负数返回，需要取负号还原 RMSE。

本章大致结果：

| 模型 | 训练 RMSE | 10 折交叉验证 RMSE | 判断 |
| --- | ---: | ---: | --- |
| 线性回归 | $68{,}973$ | $70{,}003 \pm 4{,}182$ | 欠拟合 |
| 决策树 | $0$ | $66{,}574 \pm 1{,}103$ | 严重过拟合 |
| 随机森林 | $17{,}551$ | $47{,}038 \pm 1{,}022$ | 最有希望，但仍有过拟合 |

比较训练误差和验证误差能诊断拟合状态；比较不同验证折的分数分布，还能了解评估的不确定性。

## 7. 微调模型

### 7.1 网格搜索

`GridSearchCV` 穷举给定的超参数组合，并用交叉验证比较：

```python
from sklearn.model_selection import GridSearchCV

param_grid = {
    "columntransformer__geo__n_clusters": [5, 8, 10, 15],
    "randomforestregressor__max_features": [4, 6, 8],
}

grid_search = GridSearchCV(
    full_pipeline,
    param_grid,
    cv=3,
    scoring="neg_root_mean_squared_error",
)
grid_search.fit(housing, housing_labels)
```

Pipeline 中的嵌套参数使用双下划线访问：

```text
步骤名__子步骤名__参数名
```

网格搜索适合参数数量少、候选值离散且搜索空间不大的情况。`best_estimator_` 默认会使用最佳配置在完整训练集上重新拟合。

### 7.2 随机搜索

当搜索空间大或超参数是连续值时，`RandomizedSearchCV` 更合适：

```python
from scipy.stats import randint
from sklearn.model_selection import RandomizedSearchCV

param_distributions = {
    "columntransformer__geo__n_clusters": randint(low=3, high=50),
    "randomforestregressor__max_features": randint(low=2, high=20),
}

random_search = RandomizedSearchCV(
    full_pipeline,
    param_distributions=param_distributions,
    n_iter=10,
    cv=3,
    scoring="neg_root_mean_squared_error",
    random_state=42,
)
```

优势：

- 固定 `n_iter` 可直接控制计算预算；
- 每个超参数能探索更多不同值；
- 新增无关紧要的超参数不会让训练次数指数爆炸；
- 可从统计分布中采样连续值。

经验上，对数尺度影响模型的超参数适合从对数均匀分布采样。

### 7.3 集成方法

将多个表现良好且错误模式不同的模型组合，通常比单个模型更稳健。随机森林本身就是决策树集成。后续章节会系统介绍投票、Bagging、Boosting 和 Stacking。

### 7.4 分析最佳模型和错误

随机森林的 `feature_importances_` 可以帮助理解模型依赖哪些特征：

```python
final_model = random_search.best_estimator_
importances = final_model[-1].feature_importances_
feature_names = final_model[0].get_feature_names_out()

sorted(
    zip(importances, feature_names),
    reverse=True,
)
```

本项目中，收入中位数的对数形式、是否位于内陆、卧室占比和地理相似度等特征较重要。

错误分析还应回答：

- 最大误差集中在哪些地区或价格区间？
- 高价房是否因目标截断而难以预测？
- 某些类别样本是否太少？
- 某些特征是否没有贡献，可以删除？
- 是否需要新的业务数据或更合适的损失函数？

不要只根据特征重要性机械删除特征，应通过交叉验证确认改动。

## 8. 在测试集上最终评估

确定模型与超参数后，才解锁测试集：

```python
from sklearn.metrics import root_mean_squared_error

X_test = strat_test_set.drop("median_house_value", axis=1)
y_test = strat_test_set["median_house_value"].copy()

final_predictions = final_model.predict(X_test)
final_rmse = root_mean_squared_error(y_test, final_predictions)
```

本章最终测试 RMSE 约为 $41{,}445$。可对平方误差进行 Bootstrap，估计 RMSE 的 95% 置信区间，约为 $[39{,}521, 43{,}702]$。

测试分数通常可能略差于交叉验证结果，因为开发过程已经对验证数据做了一定程度的适配。本章恰好相反，测试 RMSE 低于验证 RMSE，但无论方向如何，都不能继续使用测试集调参。如果测试结果满足上线要求，应接受这个最终估计。

测试前的检查：

- 不要在测试集上调用预处理器的 `fit()` 或 `fit_transform()`；
- 不要根据测试误差继续选择特征或超参数；
- 最终 Pipeline 应直接接受原始格式测试数据；
- 测试数据应代表未来生产请求。

## 9. 展示解决方案

技术结果应连接回业务目标。报告至少说明：

- 解决了什么业务问题；
- 使用了哪些数据，数据有哪些限制；
- 最终 Pipeline 与模型是什么；
- 测试指标和不确定性是多少；
- 与当前人工方案或基线相比改善多少；
- 哪些场景下模型容易失败；
- 上线后的监控、回退与再训练方案。

清晰的可视化和简洁陈述通常比展示所有尝试过的模型更有价值。

## 10. 上线、监控与维护

### 10.1 保存和加载完整 Pipeline

```python
import joblib

joblib.dump(final_model, "california_housing_model.pkl")
loaded_model = joblib.load("california_housing_model.pkl")
predictions = loaded_model.predict(new_data)
```

应保存完整 Pipeline，而不只是预测器，否则生产环境容易遗漏或错误复现预处理。

常见部署方式：

- 在应用进程中直接加载模型；
- 封装为 REST/gRPC 推理服务；
- 部署到云端托管模型平台；
- 根据吞吐和延迟要求配置扩缩容与负载均衡。

### 10.2 监控

至少监控：

- 服务可用性、延迟、吞吐量和错误率；
- 输入缺失值、取值范围和类别变化；
- 输入特征分布变化，即数据漂移；
- 预测值分布变化；
- 获得真实标签后的业务指标和 RMSE；
- 模型偏差、安全和公平性风险。

模型性能可能缓慢下降，也可能因上游数据格式变化突然失效。需要告警阈值、人工抽检和可快速启用的回退模型。

### 10.3 自动化维护

生产系统应逐步自动化：

1. 定期收集新数据和标签；
2. 验证数据模式、范围和质量；
3. 重新运行完整训练与调参流程；
4. 在固定评估集上比较候选模型与当前模型；
5. 保存数据、代码、参数、指标和模型版本；
6. 通过灰度或 A/B 测试逐步发布；
7. 性能下降时快速回滚。

自动训练不等于自动上线。高风险系统需要明确的审批、审计和回滚机制。

## 11. 数据泄漏检查表

| 错误做法 | 正确做法 | 风险 |
| --- | --- | --- |
| 深入探索完整数据后才划分 | 最开始锁定测试集 | 测试结果过于乐观 |
| 在全数据上拟合插补器或缩放器 | 只在训练数据上 `fit()` | 测试统计信息泄漏 |
| 先预处理再交叉验证 | 把预处理放入 Pipeline | 验证折泄漏进训练折 |
| 使用测试集选择特征和超参数 | 使用验证集或交叉验证 | 对测试集过拟合 |
| dev 与 test 中含重复或近重复实例 | 分组去重后再划分 | 泛化误差被低估 |
| 生产中手工重写预处理 | 部署完整训练 Pipeline | 训练与推理偏差 |

## 12. 核心 API 速查

| API | 作用 | 关键点 |
| --- | --- | --- |
| `train_test_split` | 划分数据 | `stratify`、`random_state` |
| `SimpleImputer` | 缺失值填补 | `strategy="median"` |
| `OneHotEncoder` | 名义类别编码 | `handle_unknown="ignore"` |
| `StandardScaler` | 标准化 | 仅在训练数据拟合 |
| `FunctionTransformer` | 用函数创建变换器 | 可提供 `inverse_func` |
| `Pipeline` / `make_pipeline` | 串联预处理和模型 | 防泄漏、可整体调参 |
| `ColumnTransformer` | 按列应用不同处理 | 数值列与类别列分流 |
| `TransformedTargetRegressor` | 变换目标变量 | 预测时自动逆变换 |
| `cross_val_score` | 交叉验证 | 损失评分可能以负数返回 |
| `GridSearchCV` | 穷举参数组合 | 适合较小离散空间 |
| `RandomizedSearchCV` | 随机参数搜索 | 适合较大或连续空间 |
| `root_mean_squared_error` | 计算 RMSE | 保持目标原始单位 |
| `joblib.dump/load` | 持久化模型 | 保存完整 Pipeline |

## 13. 章末练习与实现方向

### 练习 1：调优支持向量机回归

使用 `sklearn.svm.SVR` 比较：

- `kernel="linear"` 下不同的 `C`；
- `kernel="rbf"` 下不同的 `C` 与 `gamma`。

SVM 对大数据集扩展性较差，可只使用前 5,000 个训练实例和 3 折交叉验证。把 `SVR` 放在完整预处理 Pipeline 末尾，再通过交叉验证报告最佳 RMSE；不要先对全数据缩放。

### 练习 2：用随机搜索替换网格搜索

将 `GridSearchCV` 替换为 `RandomizedSearchCV`，为超参数选择合理分布，并比较：

- 相同训练预算下找到的最佳分数；
- 搜索过的参数范围；
- 总运行时间；
- 最佳参数是否位于原网格边界。

### 练习 3：自动选择重要特征

在预处理与回归器之间加入 `SelectFromModel`：

```python
from sklearn.feature_selection import SelectFromModel

selection_pipeline = make_pipeline(
    preprocessing,
    SelectFromModel(RandomForestRegressor(random_state=42)),
    RandomForestRegressor(random_state=42),
)
```

通过 Pipeline 参数路径搜索选择阈值，并比较特征数量、训练时间和交叉验证 RMSE。

### 练习 4：创建 KNN 地理收入特征

创建自定义 Transformer：

1. `fit()` 只使用经纬度训练 `KNeighborsRegressor`，目标是收入中位数；
2. `transform()` 输出模型对各地区收入中位数的预测；
3. 将输出作为“附近地区平滑收入”新特征加入预处理 Pipeline；
4. 搜索 `n_neighbors`、`weights` 等超参数。

这道题把“附近地区通常相似”的领域知识编码为特征，也是在练习监督式 Transformer。

### 练习 5：自动搜索预处理方案

使用 `RandomizedSearchCV` 同时探索模型参数与预处理参数，例如：

- 缺失值使用中位数还是其他策略；
- 地理聚类数量与 RBF `gamma`；
- 是否保留某些比例特征；
- One-Hot Encoder 的类别处理参数；
- 特征选择阈值。

预处理必须位于 Pipeline 内部，否则搜索过程会发生验证数据泄漏。

### 练习 6：从零实现 StandardScalerClone

实现符合 Scikit-Learn 约定的缩放器，要求：

- `fit()` 学习均值、标准差和 `n_features_in_`；
- `transform()` 执行标准化；
- `inverse_transform()` 能近似恢复原输入；
- DataFrame 输入时设置 NumPy 数组形式的 `feature_names_in_`；
- `get_feature_names_out(input_features=None)` 正确验证并返回特征名；
- 未知特征名时生成 `x0`、`x1` 等默认名称。

核心测试：

```python
scaled = scaler.fit_transform(X)
restored = scaler.inverse_transform(scaled)
np.testing.assert_allclose(restored, X)
```

还应测试常数列、NumPy 输入、DataFrame 输入和错误长度的 `input_features`。

### 练习 7：迁移到新的回归任务

选择二手车售价或共享单车需求等数据集，完整执行本章流程。重点不是获得最高排行榜分数，而是保留这些可审查产物：

- 问题定义与业务指标；
- 可复现的数据划分；
- 仅基于训练集的 EDA；
- 完整预处理与模型 Pipeline；
- 基线、交叉验证和调参记录；
- 最终测试结果与误差分析；
- 部署和监控设计。

## 14. 学习检查清单

- [ ] 能把业务需求转化为监督回归任务
- [ ] 能解释为什么本项目使用 RMSE
- [ ] 能在 EDA 前创建并锁定测试集
- [ ] 能使用分层抽样保持收入层比例
- [ ] 能从直方图识别长尾、缺失和截断
- [ ] 能解释相关系数的能力边界
- [ ] 能构造每户房间数、卧室占比等比例特征
- [ ] 能区分 `fit()`、`transform()` 和 `fit_transform()`
- [ ] 能正确处理数值缺失和名义类别
- [ ] 能用 Pipeline 防止交叉验证中的数据泄漏
- [ ] 能从训练误差与验证误差诊断拟合状态
- [ ] 能选择 Grid Search 或 Randomized Search
- [ ] 能在项目末尾只使用一次测试集
- [ ] 能保存和加载完整 Pipeline
- [ ] 能列出生产监控与模型更新计划

## 15. 本章知识压缩

```text
先定义业务，再定义模型任务和指标。
先切测试集，再探索训练集。
预处理必须可复现，并与模型组成完整 Pipeline。
训练误差用于诊断，交叉验证用于选择，测试集用于最终评估。
模型上线不是终点，还要监控数据、服务、性能和漂移。
```