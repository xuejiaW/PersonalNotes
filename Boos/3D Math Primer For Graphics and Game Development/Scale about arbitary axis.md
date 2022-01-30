---
created: 2022-01-30
updated: 2022-01-30
---
向量 $\mathbf{v}$ 沿着任意穿过原点的轴 $\mathbf{n}$ 缩放得到向量 $\mathbf{v}^{'}$ ，示意图如下：
![](assets/Scale%20about%20arbitary%20axis/image-20220130144444906.png)

如 [Rotate about arbitary axis](Rotate%20about%20arbitary%20axis.md) 推导一样，首先将向量 $\mathbf{v}$ 拆成两部分 $\mathbf{v}_{\parallel}$ 和 $\mathbf{v}_{\perp}$，其中：

$$ \mathbf{v}_{\parallel}=(\mathbf{v}\cdot\hat{n})\hat{n} \\\\\mathbf{v}_{\perp}=\mathbf{v}-v_{\parallel} $$

如果沿着轴 $\mathbf{n}$ 进行缩放， $\mathbf{v}_{\parallel}$ 将发生相应缩放，而 $\mathbf{v}_{\perp}$ 不会产生任何变化，即：

$$ \mathbf{v}_{\parallel}^{'}=k\mathbf{v}_{\parallel}=k(\mathbf{v}\cdot\hat{\mathbf{n}})\hat{\mathbf{n}} \\\\\mathbf{v}_{\perp}^{'}=\mathbf{v}_{\perp}=\mathbf{v}-\mathbf{v}_{\parallel}=\mathbf{v}-(\mathbf{v}\cdot\hat{\mathbf{n}})\hat{\mathbf{n}} $$

因此可求得 $\mathbf{v}^{'}$ ：

$$ \begin{aligned} \mathbf{v}^{'} &=\mathbf{v}_{\perp}^{'}+\mathbf{v}_{\parallel}^{'} \\& =\mathbf{v}-(\mathbf{v}\cdot\hat{\mathbf{n}})\hat{\mathbf{n}} + k(\mathbf{v}\cdot\hat{\mathbf{n}})\hat{\mathbf{n}} \\& =\mathbf{v}+(k-1)(\mathbf{v}\cdot\hat{\mathbf{n}})\hat{\mathbf{n}} \end{aligned} $$

如 [Rotate about arbitary axis](Rotate%20about%20arbitary%20axis.md) 中一样，首先将 $\mathbf{v}=\begin{bmatrix}1,0,0 \end{bmatrix}$ 待人上式，可得最终矩阵的第一行，即：

$$ \begin{aligned} \mathbf{v}^{'} &=\mathbf{v}+(k-1)(\mathbf{v}\cdot\hat{n})\hat{n} \\&={\begin{bmatrix}1 \\\\ 0 \\\\ 0\end{bmatrix}}^T + (k-1)n_x{\begin{bmatrix} n_x \\\\ n_y \\\\ n_z\end{bmatrix}}^T \\&={\begin{bmatrix}1 \\\\ 0 \\\\ 0\end{bmatrix}}^T + {\begin{bmatrix}(k-1) {n_x}^2 \\\\(k-1)n_xn_y \\\\ (k-1)n_xn_z\end{bmatrix}}^T \\&={\begin{bmatrix}1+(k-1) {n_x}^2\\\\ (k-1)n_xn_y \\\\ (k-1)n_xn_z\end{bmatrix}}^T \end{aligned} $$

同将当 $\mathbf{v}$ 以数值 $\begin{bmatrix} 0 & 1& 0\end{bmatrix}$ 代入，可得第二行，当$\mathbf{v}$ 以数值 $\begin{bmatrix} 0 & 0& 1\end{bmatrix}$ 代入，可得第三行，分别为：

$$ \mathbf{v}^{'}={\begin{bmatrix}(k-1) {n_xn_y}\\\\ 1+(k-1){n_y}^2 \\\\ (k-1)n_yn_z\end{bmatrix}}^T $$

当 $\mathbf{v}$ 以数值 $\begin{bmatrix} 0 & 0& 1\end{bmatrix}$ 代入，可得

$$ \mathbf{v}^{'}={\begin{bmatrix}(k-1) {n_xn_z}\\\\ (k-1){n_yn_z} \\\\ 1+(k-1){n_z}^2\end{bmatrix}}^T $$

至此，得到了沿任意轴缩放矩阵的三行数据，合并在一起可得：

$$ S(\hat{n},k)=\begin{bmatrix}1+(k-1) {n_x}^2&(k-1)n_xn_y &(k-1)n_xn_z \\\\(k-1) {n_xn_y}& 1+(k-1){n_y}^2 & (k-1)n_yn_z \\\\(k-1) {n_xn_z} & (k-1){n_yn_z} & 1+(k-1){n_z}^2 \\\\\end{bmatrix} $$