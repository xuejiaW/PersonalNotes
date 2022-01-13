---
created: 2022-01-13
updated: 2022-01-13
---
未被使用的 Uniform 对象在编译时会被自动剔除，因此     GL(glGetProgramiv(programID, GL_ACTIVE_UNIFORMS, &activeUniformsCount));
和 Shader 中定义的 Uniform 数量不一定一致