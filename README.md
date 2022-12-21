# onekeyRef

### 流程软件安装
```bash
sudo /mnt/d/workshop/2.IlluminaRNA-seq/one-key-pipeline/pipeline/install
mamba env create -f /opt/RNASeqWithRef/RNAseqWithRef.yml
```

### 使用
#### 激活环境
```bash
conda  activate RNAseqWithRef
```
#### 切换到包含有config和data目录的文件夹
```bash
cd /mnt/d/workshop/2.IlluminaRNA-seq/one-key-pipeline/testData
runRNAseq
```
