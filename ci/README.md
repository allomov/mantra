### How to use

```
fly set-pipeline -t tutorial -c pipeline.yml --load-vars-from stub.yml -p merrill-manifest-generator
fly unpause-pipeline -p merrill-manifest-generator
```
