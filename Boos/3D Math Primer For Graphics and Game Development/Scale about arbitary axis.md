向量 $\mathbf{v}$ 沿着任意穿过原点的轴 $\mathbf{n}$ 缩放得到向量 $\mathbf{v}^{'}$ ，示意图如下：
![](assets/Scale%20about%20arbitary%20axis/image-20220130144444906.png)

如 [Rotate about arbitary axis](Rotate%20about%20arbitary%20axis.md) 推导一样，首先将向量 $\mathbf{v}$ 拆成两部分 $\mathbf{v}_{\parallel}$ 和 $\mathbf{v}_{\perp}$，其中：

$$ \mathbf{v}_{\parallel}=(\mathbf{v}\cdot\hat{n})\hat{n} \\\\\mathbf{v}_{\perp}=\mathbf{v}-v_{\parallel} $$

如果沿着轴 $\mathbf{n}$ 进行缩放， $\mathbf{v}_{\parallel}$ 将发生相应缩放，而 $\mathbf{v}_{\perp}$ 不会产生任何变化，即：

$$ \mathbf{v}_{\parallel}^{'}=k\mathbf{v}_{\parallel}=k(\mathbf{v}\cdot\hat{\mathbf{n}})\hat{\mathbf{n}} \\\\\mathbf{v}_{\perp}^{'}=\mathbf{v}_{\perp}=\mathbf{v}-\mathbf{v}_{\parallel}=\mathbf{v}-(\mathbf{v}\cdot\hat{\mathbf{n}})\hat{\mathbf{n}} $$

因此可求得 $\mathbf{v}^{'}$ ：

$$ \begin{aligned} \mathbf{v}^{'} &=\mathbf{v}_{\perp}^{'}+\mathbf{v}_{\parallel}^{'} \\& =\mathbf{v}-(\mathbf{v}\cdot\hat{\mathbf{n}})\hat{\mathbf{n}} + k(\mathbf{v}\cdot\hat{\mathbf{n}})\hat{\mathbf{n}} \\& =\mathbf{v}+(k-1)(\mathbf{v}\cdot\hat{\mathbf{n}})\hat{\mathbf{n}} \end{aligned} $$
