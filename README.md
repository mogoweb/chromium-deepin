
# deepin Chromium

本项目基于 debian Chromium，可以在 deepin V25 系统上构建 Chromium 浏览器，构建的 deb 包可以安装并运行在统信 UOS V20 / deepin V23 / deepin V25 等信创系统上。

## 获取 deepin chromium 源码

```bash
git clone https://github.com/mogoweb/chromium-deepin.git
```

## 安装构建依赖包

进入到 chromium-deepin 目录，安装构建所需的开发包。

```
cd chromium-deepin
sudo dpkg -i ./debian/packages/libstd-rust-web-1.85_1.85.0+dfsg3-1~deb12u3_amd64.deb \
    debian/packages/libstd-rust-web-dev_1.85.0+dfsg3-1~deb12u3_amd64.deb \
    debian/packages/rustc-web_1.85.0+dfsg3-1~deb12u3_amd64.deb
sudo apt-get build-dep .
```

## 构建流程

执行以下命令，该命令会下载 Chromium 的精简版（-lite）压缩包，剔除其中的非自由组件，并生成所需的 `.orig.tar.xz` 源文件。

```
./debian/rules get-orig-source
```

生成的源码包位于上一级目录， 文件名形如： `chromium_<version>.orig.tar.xz` 。

接下来解压 `chromium_<version>.orig.tar.xz` 并将本 Git 仓库中的 `debian/` 目录复制到解压后的文件夹中：

```
tar Jxvf chromium_142.0.7444.175.orig.tar.xz
cp -ra chromium-deepin/debian chromium-142.0.7444.175
```

进入 `chromium_<version>` 目录，执行标准的 debian 包构建命令：

```
cd chromium-142.0.7444.175
dpkg-buildpackage -us -uc -b
```

这个构建过程会非常长，一般需要 2 ~ 3 个小时，甚至更长时间。

如果后续修改了 chromium 源码，不想重新构建，只需要编译修改的文件，可以使用如下命令：

```
dpkg-buildpackage -us -uc -nc
```

构建出的包位于上一级目录，通常，我们需要的浏览器包是如下两个：

```
chromium-common_142.0.7444.175-deepin1_amd64.deb
chromium_142.0.7444.175-deepin1_amd64.deb
```

## 安装chromium浏览器

```
sudo dpkg -i chromium-common_142.0.7444.175-deepin1_amd64.deb chromium_142.0.7444.175-deepin1_amd64.deb
```
