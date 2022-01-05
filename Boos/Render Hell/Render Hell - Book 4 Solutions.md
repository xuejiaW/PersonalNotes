```ad-note
这一部分会阐述解决 [Book 3 Problems](Render%20Hell%20-%20Book%203%20Problems.md) 中描述的问题的方法
```

# Sorting

对于多个 Meshes，多个 Materials 的情况，可以通过排序将同一种 Material 的 Mesh 放在一起减少 Render State 的切换，如下所示：
![|500](assets/Render%20Hell%20-%20Book%204%20Solutions/optimisation_sorting_01.gif)