
# What is SBT?

sbt is an open source build tool for Scala and Java projects, similar to Java's Maven or Ant.

> [wikipedia.org/wiki/SBT_(software))

# Usage

You can run the default `sbt` command simply:

```
 docker run -ti --rm sbt sbt sbt-version 
```

This image is configured with a workdir `/app`, so to build your project you have to mount a volume for your sources and another at `/root/.ivy2` to hold the ivy cache artifacts :

```
docker run -ti --rm -v "$PWD:/app" -v "$HOME/.ivy2":/root/.ivy2 sbt sbt clean compile
```


# License

All the code contained in this repository, unless explicitly stated, is
licensed under ISC license.

A copy of the license can be found inside the [LICENSE](LICENSE) file.
